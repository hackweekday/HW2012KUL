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

namespace Taleb.Views.FriendsViews
{
    /// <summary>
    /// Interaction logic for MainFriendsView.xaml
    /// </summary>
    public partial class MainFriendsView : UserControl
    {

        private bool IsInitialized = false;

        public MainFriendsView()
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
                    case ViewAction.ToFriendDetailedView:
                        TransitionContainer.ApplyTransition(this.FriendsListVw, this.DetailedListVw);
                        break;
                    case ViewAction.ToFriendListView:
                        TransitionContainer.ApplyTransition(this.DetailedListVw, this.FriendsListVw);
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
                                   ((ViewMessage)Message).CurrentAction == ViewAction.ToFriendDetailedView
                                   ||
                                   ((ViewMessage)Message).CurrentAction == ViewAction.ToFriendListView;
                             }
                             )
                           );
            }
        }
    }
}
