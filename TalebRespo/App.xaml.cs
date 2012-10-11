using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Windows;
using MES.Library.Mvvm;

namespace Taleb
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        public static MessageManager MsgManager;

        public App()
        {
            MsgManager = new MessageManager();
        }
    }
}
