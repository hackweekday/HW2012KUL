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
using Telerik.Windows.Controls;
using FluidKit.Controls;
using Taleb.Views.FriendsViews;
using MES.Library.Mvvm.Attributes;
using Taleb.Messages;
using Taleb.Enums;
using Taleb.Views.StartingViews;
using Taleb.Views.MainViews;
using Taleb.Views.DocsViews;
using System.Windows.Media.Animation;
using Taleb.Views.AreaViews;

namespace Taleb
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public class ViewComponent
        {
            public UserControl View { set; get; }
            public ViewType ViewT { set; get; }

            public ViewComponent()
            {}
        }

        private List<ViewComponent> ViewsList;



        public MainWindow()
        {
            StyleManager.ApplicationTheme = new MetroTheme();

            InitializeComponent();

            this.Loaded += new RoutedEventHandler(OnViewLoaded);
            this.Unloaded += new RoutedEventHandler(OnViewUnLoaded);
            this.KeyDown += new KeyEventHandler(OnKeyDown);
        }

        private void OnKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Escape)
                Application.Current.Shutdown();
        }

        private void OnViewLoaded(object sender, RoutedEventArgs e)
        {
            Initialize();
        }

        #region "Implemented Interfaces"

        [ReceiveMessage(typeof(ViewMessage), IsAllowReceive = true)]
        public void ReceiveMessage(object Message)
        {
            if (Message != null)
            {
                ViewMessage ReceivedMessage = (ViewMessage)Message;

                switch (ReceivedMessage.CurrentAction)
                {
                    case ViewAction.ChangeScreen:

                        ViewType FromType = (ViewType)ReceivedMessage.MessageObject;
                        ViewType ToType = (ViewType)ReceivedMessage.AnotherMessageObject;

                        if (FromType == ViewType.StartingView)
                        {
                            CurrentMenuBarView.UnBlockHome();
                            ((Storyboard)this.FindResource("OnLoaded1")).Begin(this);

                            App.MsgManager.PublishMessageByType<ViewMessage>
                                (
                                new ViewMessage()
                                {
                                    CurrentAction = ViewAction.StartMainAnimation
                                }
                                );
                        }

                        switch (FromType)
                        {
                            case ViewType.StartingView:
                            case ViewType.DocsView:
                            case ViewType.FriendsView:
                            case ViewType.AreaView:
                            case ViewType.MainView:

                                if (!TransitionContainer.Items.Contains(ViewsList.Where(V => V.ViewT == ToType).FirstOrDefault().View))
                                {
                                    TransitionContainer.Items.Add(ViewsList.Where(V => V.ViewT == ToType).FirstOrDefault().View);
                                    TransitionContainer.ApplyTransition(ViewsList.Where(V => V.ViewT == FromType).FirstOrDefault().View, ViewsList.Where(V => V.ViewT == ToType).FirstOrDefault().View);
                                    TransitionContainer.Items.Remove(ViewsList.Where(V => V.ViewT == FromType).FirstOrDefault().View);
                                }

                                break;

                            case ViewType.Any:

                                if (!TransitionContainer.Items.Contains(ViewsList.Where(V => V.ViewT == ToType).FirstOrDefault().View))
                                {
                                    TransitionContainer.Items.Add(ViewsList.Where(V => V.ViewT == ToType).FirstOrDefault().View);
                                    TransitionContainer.ApplyTransition(TransitionContainer.Items.GetItemAt(0) as FrameworkElement, ViewsList.Where(V => V.ViewT == ToType).FirstOrDefault().View);
                                    TransitionContainer.Items.Remove(TransitionContainer.Items.GetItemAt(0) as FrameworkElement);
                                }
                                break;
                        }

                        break;

                }
            }
        }

        #endregion

        private void OnViewUnLoaded(object sender, RoutedEventArgs e)
        {
        }

        private void Initialize()
        {
            TransitionContainer.Transition = new SlideTransition(FluidKit.Controls.Direction.LeftToRight) { Duration = TimeSpan.FromMilliseconds(1000) };
            
            ViewsList = new List<ViewComponent>();
            ViewsList.Add(new ViewComponent() { View = new MainStartingView(), ViewT = ViewType.StartingView });
            ViewsList.Add(new ViewComponent() { View = new MainView(), ViewT = ViewType.MainView });
            ViewsList.Add(new ViewComponent() { View = new MainAreasView(), ViewT = ViewType.AreaView });
            ViewsList.Add(new ViewComponent() { View = new MainFriendsView(), ViewT = ViewType.FriendsView });
            ViewsList.Add(new ViewComponent() { View = new MainDocsView(), ViewT = ViewType.DocsView });

            TransitionContainer.Items.Add(ViewsList.Where(V => V.ViewT == ViewType.StartingView).FirstOrDefault().View);
            
            App.MsgManager.SubscribeByMessageTypeAndCondition<ViewMessage>
                     (
                      this,
                      new Predicate<object>
                          (
                          (Message) =>
                          {
                              return
                                ((ViewMessage)Message).CurrentAction == ViewAction.ChangeScreen;
                          }
                          )
                        );
        }

        private void Storyboard_Completed(object sender, EventArgs e)
        {
            this.MainContainerGrid.Children.Remove(this.FadingImage);
        }
    }
}
