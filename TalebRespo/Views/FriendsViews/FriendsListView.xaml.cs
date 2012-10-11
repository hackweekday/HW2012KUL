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
using Taleb.ViewModels;

namespace Taleb.Views.FriendsViews
{
    /// <summary>
    /// Interaction logic for FriendsListView.xaml
    /// </summary>
    public partial class FriendsListView : UserControl
    {
        private bool IsInitialized = false;

        public FriendsListView()
        {
            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
            this.FriendsListBox.SelectionChanged += new SelectionChangedEventHandler(OnSelectionChanged);
        }

        private void OnSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            App.MsgManager.PublishMessageByType<ViewMessage>
                (
                new ViewMessage()
                {
                    CurrentAction = ViewAction.ToFriendDetailedView
                }
                );
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            if (!IsInitialized)
            {
                IsInitialized = true;

                this.DataContext = new FriendsListVM();
            }
        }
    }
}
