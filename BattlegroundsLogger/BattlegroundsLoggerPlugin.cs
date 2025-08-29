using System;
using System.IO;
using System.Linq;
using System.Windows.Controls;
using HearthDb.Enums;
using Hearthstone_Deck_Tracker.API;
using Hearthstone_Deck_Tracker.Enums;
using Hearthstone_Deck_Tracker.Plugins;
using Hearthstone_Deck_Tracker.Utility.Logging;
using Newtonsoft.Json;

namespace BattlegroundsLogger
{
    public class BattlegroundsLoggerPlugin : IPlugin
    {
        private BattlegroundsGameSession _currentSession;
        private Configuration _config;
        private bool _isInShopPhase;
        private int _lastRecordedTurn = -1;
        private DateTime _lastWriteTime = DateTime.MinValue;
        private const int WriteThrottleMs = 500;
        private StatusOverlay _statusOverlay;

        public string Name => "Battlegrounds Logger";
        public string Description => "Records Battlegrounds game state to JSON files for analysis (HDT v1.46.11)";
        public string ButtonText => "Settings";
        public string Author => "BG-AI";
        public Version Version => new Version(1, 0, 1);
        public MenuItem MenuItem => null;

        public void OnLoad()
        {
            Log.Info("[BG-Logger] Plugin loading...");
            LoadConfiguration();
            
            // Create and add status overlay
            _statusOverlay = new StatusOverlay();
            Core.OverlayCanvas.Children.Add(_statusOverlay);
            Canvas.SetTop(_statusOverlay, 50);
            Canvas.SetLeft(_statusOverlay, 10);
            _statusOverlay.SetStatus(LoggerStatus.WaitingForGame);
            
            GameEvents.OnGameStart.Add(OnGameStart);
            GameEvents.OnGameEnd.Add(OnGameEnd);
            GameEvents.OnTurnStart.Add(OnTurnStart);
            
            Log.Info("[BG-Logger] Plugin loaded successfully");
        }

        public void OnUnload()
        {
            Log.Info("[BG-Logger] Plugin unloading...");
            
            if (_currentSession != null)
            {
                _currentSession.EndSession();
                _currentSession = null;
            }
            
            if (_statusOverlay != null)
            {
                Core.OverlayCanvas.Children.Remove(_statusOverlay);
                _statusOverlay = null;
            }
            
            
            Log.Info("[BG-Logger] Plugin unloaded");
        }

        public void OnButtonPress()
        {
            var configWindow = new ConfigurationWindow(_config);
            configWindow.ShowDialog();
            if (configWindow.ConfigurationUpdated)
            {
                SaveConfiguration();
            }
        }

        public void OnUpdate()
        {
            try
            {
                if (!IsInBattlegroundsMatch())
                {
                    if (_statusOverlay != null && _currentSession == null)
                        _statusOverlay.SetStatus(LoggerStatus.WaitingForGame);
                    return;
                }

                if (_currentSession == null)
                    return;

                var currentTurn = GetCurrentTurn();
                if (currentTurn <= 0)
                    return;

                if (_statusOverlay != null)
                    _statusOverlay.SetStatus(LoggerStatus.Recording, currentTurn);

                if (IsInShopPhase() && currentTurn != _lastRecordedTurn)
                {
                    if (DateTime.Now - _lastWriteTime < TimeSpan.FromMilliseconds(WriteThrottleMs))
                        return;

                    if (_statusOverlay != null)
                        _statusOverlay.SetStatus(LoggerStatus.Saving, currentTurn);
                        
                    RecordShopPhaseSnapshot(currentTurn);
                    _lastRecordedTurn = currentTurn;
                    _lastWriteTime = DateTime.Now;
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error in OnUpdate: {ex}");
                if (_statusOverlay != null)
                    _statusOverlay.SetStatus(LoggerStatus.Error);
            }
        }

        private void OnGameStart()
        {
            try
            {
                if (!IsInBattlegroundsMatch())
                    return;

                Log.Info("[BG-Logger] Battlegrounds game started");
                
                _currentSession = new BattlegroundsGameSession(_config.OutputDirectory);
                _currentSession.StartSession();
                _lastRecordedTurn = -1;
                _isInShopPhase = false;
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error in OnGameStart: {ex}");
            }
        }

        private void OnGameEnd()
        {
            try
            {
                if (_currentSession == null)
                    return;

                Log.Info("[BG-Logger] Battlegrounds game ended");
                
                _currentSession.EndSession();
                _currentSession = null;
                _lastRecordedTurn = -1;
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error in OnGameEnd: {ex}");
            }
        }

        private void OnTurnStart(ActivePlayer player)
        {
            try
            {
                if (!IsInBattlegroundsMatch() || _currentSession == null)
                    return;

                var game = Core.Game;
                var gameEntity = game.Entities.Values.FirstOrDefault(e => e.Name == "GameEntity");
                if (gameEntity == null)
                    return;
                    
                var step = gameEntity.GetTag(GameTag.STEP);
                
                _isInShopPhase = (step == (int)Step.MAIN_ACTION || step == (int)Step.MAIN_READY);
                
                if (_isInShopPhase)
                {
                    Log.Info($"[BG-Logger] Shop phase started for turn {GetCurrentTurn()}");
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error in OnTurnStart: {ex}");
            }
        }

        private void RecordShopPhaseSnapshot(int turn)
        {
            try
            {
                Log.Info($"[BG-Logger] Recording snapshot for turn {turn}");
                
                var snapshot = BattlegroundsStateExtractor.ExtractCurrentState(turn);
                if (snapshot != null)
                {
                    _currentSession.SaveTurnSnapshot(turn, snapshot);
                    Log.Info($"[BG-Logger] Successfully recorded turn {turn} snapshot");
                }
                else
                {
                    Log.Warn($"[BG-Logger] Failed to extract state for turn {turn}");
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error recording snapshot: {ex}");
                _currentSession?.AddError($"Turn {turn}: {ex.Message}");
            }
        }

        private bool IsInBattlegroundsMatch()
        {
            var game = Core.Game;
            return game != null && game.IsBattlegroundsMatch && !game.IsInMenu;
        }

        private bool IsInShopPhase()
        {
            if (!_isInShopPhase)
                return false;

            var game = Core.Game;
            var gameEntity = game.Entities.Values.FirstOrDefault(e => e.Name == "GameEntity");
            if (gameEntity == null)
                return false;
                
            var step = gameEntity.GetTag(GameTag.STEP);
            
            return step == (int)Step.MAIN_ACTION || step == (int)Step.MAIN_READY;
        }

        private int GetCurrentTurn()
        {
            var game = Core.Game;
            if (game == null)
                return -1;

            var turnNumber = game.GetTurnNumber();
            
            return (turnNumber + 1) / 2;
        }

        private void LoadConfiguration()
        {
            try
            {
                var configPath = Path.Combine(GetPluginDirectory(), "config.json");
                if (File.Exists(configPath))
                {
                    var json = File.ReadAllText(configPath);
                    _config = JsonConvert.DeserializeObject<Configuration>(json);
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error loading configuration: {ex}");
            }

            if (_config == null)
            {
                _config = new Configuration();
                SaveConfiguration();
            }
        }

        private void SaveConfiguration()
        {
            try
            {
                var configPath = Path.Combine(GetPluginDirectory(), "config.json");
                var json = JsonConvert.SerializeObject(_config, Formatting.Indented);
                File.WriteAllText(configPath, json);
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error saving configuration: {ex}");
            }
        }

        private string GetPluginDirectory()
        {
            var assemblyLocation = System.Reflection.Assembly.GetExecutingAssembly().Location;
            return Path.GetDirectoryName(assemblyLocation);
        }
    }
}