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
using Taleb.Enums;

namespace Taleb.Views.MainViews
{
    /// <summary>
    /// Interaction logic for MainView.xaml
    /// </summary>
    public partial class MainView : UserControl
    {
        public MainView()
        {
            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            this.FriendsImage.PreviewTouchUp +=
                (S, E) =>
                {
                    App.MsgManager.PublishMessageByType<ViewMessage>
                        (
                        new ViewMessage()
                        {
                            CurrentAction = ViewAction.ChangeScreen,
                            MessageObject = ViewType.MainView,
                            AnotherMessageObject = ViewType.FriendsView
                        }
                        );
                };

            this.DocsImage.PreviewTouchUp +=
                (S, E) =>
                {
                    App.MsgManager.PublishMessageByType<ViewMessage>
                        (
                        new ViewMessage()
                        {
                            CurrentAction = ViewAction.ChangeScreen,
                            MessageObject = ViewType.MainView,
                            AnotherMessageObject = ViewType.DocsView
                        }
                        );
                };

            this.AreasImage.PreviewTouchUp +=
                (S, E) =>
                {
                    App.MsgManager.PublishMessageByType<ViewMessage>
                        (
                        new ViewMessage()
                        {
                            CurrentAction = ViewAction.ChangeScreen,
                            MessageObject = ViewType.MainView,
                            AnotherMessageObject = ViewType.AreaView
                        }
                        );
                };
        }
    }
}
