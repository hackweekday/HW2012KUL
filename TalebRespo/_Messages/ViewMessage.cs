using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MES.Library.Mvvm.Base;

namespace Taleb.Messages
{
    public enum ViewAction
    {
        ChangeScreen,
        ToFriendDetailedView,
        ToFriendListView,
        ToSecondStartingView,
        ToThirdStartingView,
        ToOneAreaView,
        ToAllAreaView,
        StartMainAnimation
    }

    public class ViewMessage : MessageBase
    {
        public override object MessageObject
        {
            get
            {
                return base.MessageObject;
            }
            set
            {
                base.MessageObject = value;
            }
        }

        public object AnotherMessageObject
        {
            get;
            set;
        }

        public ViewAction CurrentAction
        {
            set;
            get;
        }

        public ViewMessage()
            : base()
        {
        }

    }
}
