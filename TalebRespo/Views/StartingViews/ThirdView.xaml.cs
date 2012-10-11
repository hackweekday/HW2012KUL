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

namespace Taleb.Views.StartingViews
{
    /// <summary>
    /// Interaction logic for ThirdView.xaml
    /// </summary>
    public partial class ThirdView : UserControl
    {
        public ThirdView()
        {
            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            this.ToMainViewButton.PreviewTouchUp +=
                (S, E) =>
                {
                    App.MsgManager.PublishMessageByType<ViewMessage>
                        (
                        new ViewMessage()
                        {
                            CurrentAction = ViewAction.ChangeScreen,
                            MessageObject = ViewType.StartingView,
                            AnotherMessageObject = ViewType.MainView
                        }
                        );
                };
        }
    }
}
