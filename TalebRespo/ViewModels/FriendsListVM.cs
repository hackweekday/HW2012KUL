using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.ObjectModel;
using Taleb.Models;
using System.Windows.Input;
using MES.Library.Mvvm;

namespace Taleb.ViewModels
{
    public class FriendsListVM : MES.Library.Mvvm.ViewModelBase
    {
        public ObservableCollection<Friend> Friends
        { set; get; }

        public ICommand _AllFriends;
        public ICommand AllFriends
        {
            set { _AllFriends = value; }
            get { return _AllFriends; }
        }

        public ICommand _Online;
        public ICommand Online
        {
            set { _Online = value; }
            get { return _Online; }
        }

        public ICommand _Nearby;
        public ICommand Nearby
        {
            set { _Nearby = value; }
            get { return _Nearby; }
        }

        public FriendsListVM()
        {
            Friends = new ObservableCollection<Friend>();

            Random Rnd = new Random(DateTime.Now.Millisecond);

            for (int i = 0; i < 50;  i++ )
                Friends.Add(new Friend() { Name = "John", ID = Rnd.Next(1, 10000000).ToString() });


            _AllFriends = new SimpleCommand<object>
               (
               new Action<object>
                   (
                   (Arg) =>
                   {
                       Friends.Clear();

                       for (int i = 0; i < 50; i++)
                           Friends.Add(new Friend() { Name = "John", ID = Rnd.Next(1, 10000000).ToString() });
                   }
                   )
               );

            _Nearby = new SimpleCommand<object>
               (
               new Action<object>
                   (
                   (Arg) =>
                   {
                       Friends.Clear();

                       for (int i = 0; i < 3; i++)
                           Friends.Add(new Friend() { Name = "Richard Jacquier", ID = Rnd.Next(1, 10000000).ToString() });
                   }
                   )
               );

            _Online = new SimpleCommand<object>
               (
               new Action<object>
                   (
                   (Arg) =>
                   {
                       Friends.Clear();

                       for (int i = 0; i < 10; i++)
                           Friends.Add(new Friend() { Name = "Ian Atkin", ID = Rnd.Next(1, 10000000).ToString() });
                   }
                   )
               );

        }
    }
}
