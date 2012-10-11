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
using MES.Library.Mvvm.Attributes;
using Taleb.Messages;
using FluidKit.Controls;

namespace Taleb.Views.StartingViews
{
    /// <summary>
    /// Interaction logic for MainStartingView.xaml
    /// </summary>
    public partial class MainStartingView  : UserControl
    {
        private bool IsInitialized = false;

        public MainStartingView()
        {
            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            Initialize();
        }

        [ReceiveMessage(typeof(ViewMessage), IsAllowReceive = true)]
        public void ReceiveMessage(object Message)
        {
            if (Message != null)
            {
                ViewMessage ReceivedMessage = (ViewMessage)Message;

                switch (ReceivedMessage.CurrentAction)
                {
                    case ViewAction.ToSecondStartingView:
                        TransitionContainer.ApplyTransition(this.FView, this.SView);
                        break;
                    case ViewAction.ToThirdStartingView:
                        TransitionContainer.ApplyTransition(this.SView, this.ThrView);
                        break;
                }
            }
        }


        private void Initialize()
        {
            if (!IsInitialized)
            {
                IsInitialized = true;

                TransitionContainer.Transition = new SlideTransition(FluidKit.Controls.Direction.TopToBottom) { Duration = TimeSpan.FromMilliseconds(600) };

                App.MsgManager.SubscribeByMessageTypeAndCondition<ViewMessage>
                        (
                         this,
                         new Predicate<object>
                             (
                             (Message) =>
                             {
                                 return
                                   ((ViewMessage)Message).CurrentAction == ViewAction.ToSecondStartingView
                                   ||
                                   ((ViewMessage)Message).CurrentAction == ViewAction.ToThirdStartingView;
                             }
                             )
                           );
            }
        }
    }
}
