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
using System.Windows.Media.Animation;

namespace Taleb.Views.MainViews
{
    /// <summary>
    /// Interaction logic for MenuBarView.xaml
    /// </summary>
    public partial class MenuBarView : UserControl
    {
        private bool IsBlockHome = true;

        public MenuBarView()
        {
            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            this.TalebTextBlock.PreviewTouchUp +=
                (S, E) =>
                {
                    if (!IsBlockHome)
                    {
                        App.MsgManager.PublishMessageByType<ViewMessage>
                            (
                            new ViewMessage()
                            {
                                CurrentAction = ViewAction.ChangeScreen,
                                MessageObject = ViewType.Any,
                                AnotherMessageObject = ViewType.MainView
                            }
                            );
                    }
                };
        }

        public void UnBlockHome()
        {
            IsBlockHome = false;
            ((Storyboard)this.FindResource("OnLoaded1")).Begin(this);
        }
    }
}
