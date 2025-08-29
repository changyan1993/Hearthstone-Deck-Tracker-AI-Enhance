#region

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Documents;
using Hearthstone_Deck_Tracker.Controls.Error;
using Hearthstone_Deck_Tracker.Hearthstone;
using Hearthstone_Deck_Tracker.LogReader.Handlers;
using Hearthstone_Deck_Tracker.Utility.Logging;
using Hearthstone_Deck_Tracker.Windows;
using HearthWatcher;
using HearthWatcher.LogReader;
using static Hearthstone_Deck_Tracker.API.LogEvents;

#endregion

namespace Hearthstone_Deck_Tracker.LogReader
{
	public class LogWatcherManager
	{
		private readonly PowerHandler _powerLineHandler = new PowerHandler();
		private readonly GameInfoHandler _gameInfoHandler = new GameInfoHandler();
		private readonly ChoicesHandler _choicesHandler = new ChoicesHandler();
		private readonly ArenaHandler _arenaHandler = new ArenaHandler();
		private readonly LoadingScreenHandler _loadingScreenHandler = new LoadingScreenHandler();
		private HsGameState? _gameState;
		private GameV2? _game;
		private readonly LogWatcher _logWatcher;
		private bool _stop;
		private int _processedLogLines = 0;
		private DateTime _lastConnectionLog = DateTime.MinValue;

		internal bool IsEnabled { get; set; } = true;

		public static LogWatcherInfo AchievementsLogWatcherInfo => new LogWatcherInfo { Name = "Achievements" };
		public static LogWatcherInfo PowerLogWatcherInfo => new LogWatcherInfo
		{
			Name = "Power",
			StartsWithFilters = new[] {"PowerTaskList.DebugPrintPower", "GameState.", "PowerProcessor.EndCurrentTaskList"},
			ContainsFilters = new[] {"Begin Spectating", "Start Spectator", "End Spectator"}
		};

		public static LogWatcherInfo ArenaLogWatcherInfo => new LogWatcherInfo {Name = "Arena" };
		public static LogWatcherInfo LoadingScreenLogWatcherInfo => new LogWatcherInfo {Name = "LoadingScreen", StartsWithFilters = new[] {"LoadingScreen.OnSceneLoaded", "Gameplay", "LoadingScreen.OnScenePreUnload", "MulliganManager.HandleGameStart" } };

		public LogWatcherManager()
		{
			_logWatcher = new LogWatcher(new []
			{
				AchievementsLogWatcherInfo,
				PowerLogWatcherInfo,
				ArenaLogWatcherInfo,
				LoadingScreenLogWatcherInfo,
			});
			_logWatcher.OnNewLines += OnNewLines;
			_logWatcher.OnLogFileFound += OnLogFileFound;
			_logWatcher.OnLogLineIgnored += OnLogLineIgnored;
		}

		private void OnLogFileFound(string msg) => Log.Info($"📋 {msg}");
		private void OnLogLineIgnored(string msg) => Log.Warn($"⚠️ {msg}");

		public async Task Start(GameV2 game)
		{
			if(!IsEnabled)
			{
				Log.Warn("🚫 LogWatcherManager is disabled - HDT will not connect to Hearthstone");
				return;
			}

			Log.Info("🚀 Starting HDT LogWatcherManager...");
			
			if(!Helper.HearthstoneDirExists)
			{
				Log.Info("📂 Hearthstone directory not configured, attempting to find Hearthstone...");
				await FindHearthstone();
			}
			else
			{
				Log.Info($"📁 Using existing Hearthstone directory: '{Config.Instance.HearthstoneDirectory}'");
				
				// Verify the process is still running
				var proc = User32.GetHearthstoneProc();
				if(proc != null)
				{
					Log.Info($"✅ Hearthstone process confirmed running - PID: {proc.Id}");
				}
				else
				{
					Log.Warn("⚠️ Hearthstone process not detected, but directory is configured");
				}
			}
			
			InitializeGameState(game);
			_stop = false;
			var logDirectory = Path.Combine(Config.Instance.HearthstoneDirectory, Config.Instance.HearthstoneLogsDirectoryName);
			Log.Info($"📄 Monitoring Hearthstone log directory: '{logDirectory}'");
			Log.Info("🔄 Starting log file watcher...");
			_logWatcher.Start(logDirectory);
			Log.Info("✅ HDT LogWatcher started successfully - Ready to track your games!");
		}

		private async Task FindHearthstone()
		{
			Log.Warn("🔍 Hearthstone not found, waiting for process...");
			Log.Info("📋 HDT is scanning for running Hearthstone process every 500ms");
			Process? proc;
			var attempts = 0;
			while((proc = User32.GetHearthstoneProc()) == null)
			{
				attempts++;
				if(attempts % 10 == 0) // Log every 5 seconds (500ms * 10)
					Log.Info($"⏳ Still waiting for Hearthstone... ({attempts * 0.5:F1}s elapsed)");
				await Task.Delay(500);
			}
			
			Log.Info($"🎯 HEARTHSTONE PROCESS DETECTED! PID: {proc.Id}, Process Name: {proc.ProcessName}");
			
			var dir = new FileInfo(proc.MainModule.FileName).Directory?.FullName;
			if(dir == null)
			{
				const string msg = "❌ Could not find Hearthstone installation directory";
				Log.Error(msg);
				ErrorManager.AddError(msg, "Please point HDT to your Hearthstone installation via 'options > tracker > settings > set hearthstone path'.");
				return;
			}
			Log.Info($"✅ HEARTHSTONE DIRECTORY FOUND: '{dir}'");
			Log.Info($"🔗 HDT successfully connected to Hearthstone!");
			Config.Instance.HearthstoneDirectory = dir;
			Config.Save();
		}

		public async Task<bool> Stop(bool force = false)
		{
			_stop = true;
			return await _logWatcher.Stop(force);
		}

		private void InitializeGameState(GameV2 game)
		{
			_game = game;
			_gameState = new HsGameState(game) { GameHandler = new GameEventHandler(game) };
			_gameState.Reset();
		}

		private void OnNewLines(List<LogLine> lines)
		{
			if(_game == null || _gameState == null)
				return;
				
			// Log connection activity periodically
			_processedLogLines += lines.Count;
			var now = DateTime.Now;
			if (now - _lastConnectionLog > TimeSpan.FromMinutes(1) && _processedLogLines > 0)
			{
				Log.Info($"🔄 HDT ↔ Hearthstone: Active connection confirmed! Processed {_processedLogLines} log lines in the last minute");
				_lastConnectionLog = now;
				_processedLogLines = 0;
			}
			
			foreach(var line in lines)
			{
				if(_stop)
					break;
				_game.GameTime.Time = line.Time;
				switch(line.Namespace)
				{
					case "Achievements":
						OnAchievementsLogLine.Execute(line.Line);
						break;
					case "Power":
						if(line.LineContent.StartsWith("GameState."))
						{
							_game.PowerLog.Add(line.Line);
							if(
								line.LineContent.StartsWith("GameState.DebugPrintEntityChoices") ||
								line.LineContent.StartsWith("GameState.DebugPrintEntitiesChosen")
							)
							{
								_choicesHandler.Handle(line.Line, _gameState, _game);
							}
							else {
								_choicesHandler.Flush(_gameState, _game);
							}

							if(line.LineContent.StartsWith("GameState.DebugPrintGame"))
							{
								_gameInfoHandler.Handle(line.Line, _gameState, _game);
							}
						}
						else if(line.LineContent.StartsWith("PowerProcessor.EndCurrentTaskList"))
						{
							_choicesHandler.Handle(line.Line, _gameState, _game);
						}
						else
						{
							_powerLineHandler.Handle(line.Line, _gameState, _game);
							OnPowerLogLine.Execute(line.Line);
							_choicesHandler.Flush(_gameState, _game);
						}
						break;
					case "Arena":
						_arenaHandler.Handle(line, _gameState, _game);
						OnArenaLogLine.Execute(line.Line);
						break;
					case "LoadingScreen":
						_loadingScreenHandler.Handle(line, _gameState, _game);
						break;
				}
			}
			Helper.UpdateEverything(_game);
		}
	}
}
