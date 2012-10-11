using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Taleb.Models;
using System.Collections.ObjectModel;

namespace Taleb.ViewModels
{
    public class OneAreaVM: MES.Library.Mvvm.ViewModelBase
    {
        public ObservableCollection<Friend> Friends
        { set; get; }


        public OneAreaVM()
        {
            Friends = new ObservableCollection<Friend>();

            Random Rnd = new Random(DateTime.Now.Millisecond);

            for (int i = 0; i < 9;  i++ )
                Friends.Add(new Friend() { Name = "John", ID = Rnd.Next(1, 10000000).ToString() });
        }
    }
}
