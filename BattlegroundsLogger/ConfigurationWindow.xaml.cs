using System;
using System.Windows;
using System.Windows.Forms;

namespace BattlegroundsLogger
{
    public partial class ConfigurationWindow : Window
    {
        private Configuration _config;
        public bool ConfigurationUpdated { get; private set; }

        public ConfigurationWindow(Configuration config)
        {
            InitializeComponent();
            _config = config;
            LoadConfiguration();
        }

        private void LoadConfiguration()
        {
            OutputDirectoryTextBox.Text = _config.OutputDirectory;
            EnableLoggingCheckBox.IsChecked = _config.EnableLogging;
            VerboseLoggingCheckBox.IsChecked = _config.VerboseLogging;
            MaxSessionsTextBox.Text = _config.MaxSessionsToKeep.ToString();
        }

        private void BrowseButton_Click(object sender, RoutedEventArgs e)
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.Description = "Select output directory for Battlegrounds logs";
                dialog.SelectedPath = _config.OutputDirectory;
                
                if (dialog.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                {
                    OutputDirectoryTextBox.Text = dialog.SelectedPath;
                }
            }
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            _config.OutputDirectory = OutputDirectoryTextBox.Text;
            _config.EnableLogging = EnableLoggingCheckBox.IsChecked ?? true;
            _config.VerboseLogging = VerboseLoggingCheckBox.IsChecked ?? false;
            
            if (int.TryParse(MaxSessionsTextBox.Text, out int maxSessions))
            {
                _config.MaxSessionsToKeep = Math.Max(0, maxSessions);
            }

            ConfigurationUpdated = true;
            this.Close();
        }

        private void CancelButton_Click(object sender, RoutedEventArgs e)
        {
            ConfigurationUpdated = false;
            this.Close();
        }
    }
}