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

using Telerik.Windows.Controls;
using Microsoft.Surface.Presentation.Controls;

namespace Taleb.Views.AreaViews
{
    /// <summary>
    /// Interaction logic for OneAreaView.xaml
    /// </summary>
    public partial class OneAreaView : UserControl
    {
        private bool IsInitialized = false;

        public static readonly DependencyProperty SelectedProperty =
         DependencyProperty.RegisterAttached("Selected", typeof(bool), typeof(OneAreaView),
         new PropertyMetadata(new PropertyChangedCallback(OnSelectedChanged)));

        // Purpose: Once the RadPane header is initialized, then we will de-attach any old event, and attach a new onclosing event
        private static void OnSelectedChanged(DependencyObject Obj, DependencyPropertyChangedEventArgs Args)
        {
            FrameworkElement TemporaryElement = Obj as FrameworkElement;

            if (TemporaryElement != null)
            {
                TemporaryElement.PreviewTouchUp += (s, e) =>
                    {
                        App.MsgManager.PublishMessageByType<ViewMessage>
                           (
                           new ViewMessage()
                           {
                               CurrentAction = ViewAction.ToAllAreaView
                           }
                           );
                    };
            }
        }



        public static bool GetSelected(DependencyObject obj)
        {
            return (bool)obj.GetValue(SelectedProperty);
        }

        public static void SetSelected(DependencyObject obj, bool value)
        {
            obj.SetValue(SelectedProperty, value);
        }


        public OneAreaView()
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

                this.DataContext = new OneAreaVM();

                List<String> Items = new List<string>() { "sAS", "Ite22asdms", "Iteasms", "Itedms", "Ite12ms", "Itemdass", "fa", "Itafffsems", "ffftems", "123", "33sa", "312", "3123asd", "3123dascgg", "asd", "dda", "d", "A", "dgg", "dasd" };
                AreasTileView.ItemsSource = Items;
            }
        }
    }
}
