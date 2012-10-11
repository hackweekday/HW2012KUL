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
using Telerik.Windows;
using Telerik.Windows.Controls;
using Taleb.Messages;

namespace Taleb.Views.FriendsViews
{
    /// <summary>
    /// Interaction logic for DetailedFriendView.xaml
    /// </summary>
    public partial class DetailedFriendView : UserControl
    {
        private bool IsInitialized = false;

        public DetailedFriendView()
        {
            InitializeComponent();
            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            if (!IsInitialized)
            {
                IsInitialized = true;

                this.DocsTileView.TileStateChanged += new EventHandler<RadRoutedEventArgs>(OnTileStateChanged);

                this.BackImage.PreviewTouchUp += (S, E) =>
                    {
                        App.MsgManager.PublishMessageByType<ViewMessage>
                            (
                            new ViewMessage()
                            {
                                CurrentAction = ViewAction.ToFriendListView
                            }
                            );
                    };

                List<String> Items = new List<string>() { "sAS", "Ite22asdms", "Iteasms", "Itedms", "Ite12ms", "Itemdass", "fa", "Itafffsems", "ffftems", "123", "33sa", "312", "3123asd", "3123dascgg", "asd", "dda", "d", "A", "dgg", "dasd" };
                DocsTileView.ItemsSource = Items;

                for (int i = 0; i < 100; i++)
                {
                    this.ChatListBox.Items.Add("Hello !");
                }
            }
        }


        private void OnTileStateChanged(object sender, RadRoutedEventArgs e)
        {
            RadTileViewItem item = e.OriginalSource as RadTileViewItem;
            if (item != null)
            {
                RadFluidContentControl fluid = item.ChildrenOfType<RadFluidContentControl>().FirstOrDefault();
                if (fluid != null)
                {
                    switch (item.TileState)
                    {
                        case TileViewItemState.Maximized:
                            fluid.State = FluidContentControlState.Large;
                            break;
                        case TileViewItemState.Minimized:
                            fluid.State = FluidContentControlState.Small;
                            break;
                        case TileViewItemState.Restored:
                            fluid.State = FluidContentControlState.Normal;
                            break;
                        default:
                            break;
                    }

                }
            }
        }
    }
}
