using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Taleb.Messages;

namespace Taleb.Views.StartingViews
{
    /// <summary>
    /// Interaction logic for FirstView.xaml
    /// </summary>
    public partial class FirstView : UserControl
    {
        private bool IsInitialized = false;

        public FirstView()
        {
            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            if (!IsInitialized)
            {
                IsInitialized = true;


                this.FBImage.PreviewTouchUp += (S, E) =>
                {
                    App.MsgManager.PublishMessageByType<ViewMessage>
                        (
                        new ViewMessage()
                        {
                            CurrentAction = ViewAction.ToSecondStartingView
                        }
                        );
                };

                this.GPlusImage.PreviewTouchUp += (S, E) =>
                {
                    App.MsgManager.PublishMessageByType<ViewMessage>
                        (
                        new ViewMessage()
                        {
                            CurrentAction = ViewAction.ToSecondStartingView
                        }
                        );
                };
            }
        }
    }
}
