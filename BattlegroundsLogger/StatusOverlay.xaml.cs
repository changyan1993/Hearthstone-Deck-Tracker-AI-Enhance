using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Animation;

namespace BattlegroundsLogger
{
    public partial class StatusOverlay : UserControl
    {
        private Storyboard _pulseAnimation;

        public StatusOverlay()
        {
            InitializeComponent();
            CreatePulseAnimation();
            SetStatus(LoggerStatus.Idle);
        }

        private void CreatePulseAnimation()
        {
            _pulseAnimation = new Storyboard();
            var animation = new DoubleAnimation
            {
                From = 1.0,
                To = 0.3,
                Duration = new Duration(TimeSpan.FromSeconds(0.5)),
                AutoReverse = true,
                RepeatBehavior = RepeatBehavior.Forever
            };
            Storyboard.SetTarget(animation, StatusLight);
            Storyboard.SetTargetProperty(animation, new PropertyPath(UIElement.OpacityProperty));
            _pulseAnimation.Children.Add(animation);
        }

        public void SetStatus(LoggerStatus status, int turn = 0)
        {
            Dispatcher.BeginInvoke(new Action(() =>
            {
                switch (status)
                {
                    case LoggerStatus.Idle:
                        StatusLight.Fill = Brushes.Gray;
                        StatusText.Text = "BG Logger: Idle";
                        TurnCounter.Text = "";
                        _pulseAnimation.Stop();
                        StatusLight.Opacity = 1.0;
                        break;

                    case LoggerStatus.WaitingForGame:
                        StatusLight.Fill = Brushes.Yellow;
                        StatusText.Text = "BG Logger: Ready";
                        TurnCounter.Text = "";
                        _pulseAnimation.Stop();
                        StatusLight.Opacity = 1.0;
                        break;

                    case LoggerStatus.Recording:
                        StatusLight.Fill = Brushes.LimeGreen;
                        StatusText.Text = "BG Logger: Recording";
                        TurnCounter.Text = $"Turn: {turn}";
                        _pulseAnimation.Begin();
                        break;

                    case LoggerStatus.Saving:
                        StatusLight.Fill = Brushes.Orange;
                        StatusText.Text = "BG Logger: Saving...";
                        TurnCounter.Text = $"Turn: {turn}";
                        _pulseAnimation.Begin();
                        break;

                    case LoggerStatus.Error:
                        StatusLight.Fill = Brushes.Red;
                        StatusText.Text = "BG Logger: Error";
                        TurnCounter.Text = "";
                        _pulseAnimation.Stop();
                        StatusLight.Opacity = 1.0;
                        break;
                }
            }));
        }

        public void Show()
        {
            Dispatcher.BeginInvoke(new Action(() => Visibility = Visibility.Visible));
        }

        public void Hide()
        {
            Dispatcher.BeginInvoke(new Action(() => Visibility = Visibility.Collapsed));
        }
    }

    public enum LoggerStatus
    {
        Idle,
        WaitingForGame,
        Recording,
        Saving,
        Error
    }
}