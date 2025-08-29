using System;
using System.IO;

namespace BattlegroundsLogger
{
    public class Configuration
    {
        public string OutputDirectory { get; set; }
        public bool EnableLogging { get; set; }
        public bool VerboseLogging { get; set; }
        public int MaxSessionsToKeep { get; set; }

        public Configuration()
        {
            var defaultPath = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
                "BG-AI-Logs"
            );
            
            OutputDirectory = defaultPath;
            EnableLogging = true;
            VerboseLogging = false;
            MaxSessionsToKeep = 0;
        }

        public void EnsureDirectoryExists()
        {
            if (!Directory.Exists(OutputDirectory))
            {
                Directory.CreateDirectory(OutputDirectory);
            }
        }
    }
}