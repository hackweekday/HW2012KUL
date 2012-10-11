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
using System.ComponentModel;
using System.Windows.Media.Animation;
using MES.Library.Mvvm.Attributes;
using Taleb.Messages;

namespace Taleb.Views.MainViews
{
    /// <summary>
    /// Interaction logic for ShoutoutsView.xaml
    /// </summary>
    public partial class ShoutoutsView : UserControl, INotifyPropertyChanged
    {
        #region "INotifyPropertyChanged Logic"

        // Purpose: Public PropertyChangedEventHandler [Delegate] which will be fired in case any property had been changed
        public event PropertyChangedEventHandler PropertyChanged;

        public void FirePropertyChanged(String PropertyName)
        {
            if (PropertyChanged != null)
                PropertyChanged(this, new PropertyChangedEventArgs(PropertyName));
        }

        #endregion

        private bool IsInitialized = false;

        public ShoutoutsView()
        {
            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {

            if (!IsInitialized)
            {
                IsInitialized = true;

                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");
                this.ShoutoutsListBox.Items.Add("Hello Earth!");

                App.MsgManager.SubscribeByMessageTypeAndCondition<ViewMessage>
                    (
                     this,
                     new Predicate<object>
                         (
                         (Message) =>
                         {
                             return
                               ((ViewMessage)Message).CurrentAction == ViewAction.StartMainAnimation;
                         }
                         )
                       );
            }
        }

        [ReceiveMessage(typeof(ViewMessage), IsAllowReceive = true)]
        public void ReceiveMessage(object Message)
        {
            if (Message != null)
            {
                ViewMessage ReceivedMessage = (ViewMessage)Message;

                switch (ReceivedMessage.CurrentAction)
                {
                    case ViewAction.StartMainAnimation:
                        ((Storyboard)this.FindResource("OnLoaded1")).Begin(this);
                        break;
                }
            }
        }
    }
}
