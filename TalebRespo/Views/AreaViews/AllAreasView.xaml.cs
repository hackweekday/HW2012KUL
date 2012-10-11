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
using Taleb.ViewModels;
using Taleb.Messages;
using Taleb.Enums;

namespace Taleb.Views.AreaViews
{
    /// <summary>
    /// Interaction logic for AllAreasView.xaml
    /// </summary>
    public partial class AllAreasView : UserControl
    {

        private bool IsInitialized = false;


        public AllAreasView()
        {
            InitializeComponent(); 
            
            this.Loaded += new RoutedEventHandler(OnViewLoaded);
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            if (!IsInitialized)
            {
                IsInitialized = true;

                this.BackImage.PreviewTouchUp += (S, E) =>
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
                };

                List<String> Items = new List<string>() { "sAS", "Ite22asdms", "Iteasms", "Itedms", "Ite12ms", "Itemdass", "fa", "Itafffsems", "ffftems", "123", "33sa", "312", "3123asd", "3123dascgg", "asd", "dda", "d", "A", "dgg", "dasd" };
                DocsTileView.ItemsSource = Items;

                this.DataContext = new OneAreaVM();
            }
        }
    }
}
