
// Note: This sample have been modified for DICOM-Wave from Microsoft.Samples.Kinect.Slideshow
// on 10/10/2012

namespace DicomWave.GestureComponent
  {
  using System;
  using System.Collections.Generic;
  using System.ComponentModel;
  using System.Diagnostics;
  using System.IO;
  using System.Windows;
  using System.Windows.Media;
  using System.Windows.Media.Animation;
  using System.Windows.Media.Imaging;
  using System.Windows.Shapes;
  using Microsoft.Kinect;
  using Microsoft.Samples.Kinect.SwipeGestureRecognizer;

  public partial class MainWindow : Window, INotifyPropertyChanged
    {
    private readonly Recognizer activeRecognizer;
    private readonly string[] picturePaths = CreatePicturePaths();

    private static readonly JointType[][] SkeletonSegmentRuns = new JointType[][]
          {
            new JointType[] 
              { 
                JointType.Head, JointType.ShoulderCenter, JointType.HipCenter 
              },
            new JointType[] 
              { 
                JointType.HandLeft, JointType.WristLeft, JointType.ElbowLeft, JointType.ShoulderLeft,
                JointType.ShoulderCenter,
                JointType.ShoulderRight, JointType.ElbowRight, JointType.WristRight, JointType.HandRight
              },
            new JointType[]
              {
                JointType.FootLeft, JointType.AnkleLeft, JointType.KneeLeft, JointType.HipLeft,
                JointType.HipCenter,
                JointType.HipRight, JointType.KneeRight, JointType.AnkleRight, JointType.FootRight
              }
          };

    /// <summary>
    /// The sensor we're currently tracking.
    /// </summary>
    private KinectSensor nui;
    private bool isDisconnectedField = true;
    private string disconnectedReasonField;
    private Skeleton[] skeletons = new Skeleton[0];

    /// <summary>
    /// Time until skeleton ceases to be highlighted.
    /// </summary>
    private DateTime highlightTime = DateTime.MinValue;

    /// <summary>
    /// The ID of the skeleton to highlight.
    /// </summary>
    private int highlightId = -1;

    /// <summary>
    /// The ID if the skeleton to be tracked.
    /// </summary>
    private int nearestId = -1;

    /// <summary>
    /// The index of the current image.
    /// </summary>
    private int indexField = 1;

    public MainWindow()
      {
      this.PreviousPicture = this.LoadPicture(this.Index - 1);
      this.Picture = this.LoadPicture(this.Index);
      this.NextPicture = this.LoadPicture(this.Index + 1);

      InitializeComponent();

      // Create the gesture recognizer.
      this.activeRecognizer = this.CreateRecognizer();

      // Wire-up window loaded event.
      Loaded += this.OnMainWindowLoaded;
      }

    public event PropertyChangedEventHandler PropertyChanged;

    public bool IsDisconnected
      {
      get
        {
        return this.isDisconnectedField;
        }

      private set
        {
        if (this.isDisconnectedField != value)
          {
          this.isDisconnectedField = value;

          if (this.PropertyChanged != null)
            {
            this.PropertyChanged(this, new PropertyChangedEventArgs("IsDisconnected"));
            }
          }
        }
      }

    public string DisconnectedReason
      {
      get
        {
        return this.disconnectedReasonField;
        }

      private set
        {
        if (this.disconnectedReasonField != value)
          {
          this.disconnectedReasonField = value;

          if (this.PropertyChanged != null)
            {
            this.PropertyChanged(this, new PropertyChangedEventArgs("DisconnectedReason"));
            }
          }
        }
      }

    public int Index
      {
      get
        {
        return this.indexField;
        }

      set
        {
        if (this.indexField != value)
          {
          this.indexField = value;

          // Notify world of change to Index and Picture.
          if (this.PropertyChanged != null)
            {
            this.PropertyChanged(this, new PropertyChangedEventArgs("Index"));
            }
          }
        }
      }

    public BitmapImage PreviousPicture { get; private set; }
    public BitmapImage Picture { get; private set; }
    public BitmapImage NextPicture { get; private set; }

    private static string[] CreatePicturePaths()
      {
      var list = new List<string>();

      var commonPicturesPath = "C:\\_MedData\\_MedTemp\\"; //hardcoded from DicomWave project
      list.AddRange(Directory.GetFiles(commonPicturesPath, "*.jpg", SearchOption.AllDirectories));
      if (list.Count == 0)
        {
        list.AddRange(Directory.GetFiles(commonPicturesPath, "*.png", SearchOption.AllDirectories));
        }

      if (list.Count == 0)
        {
        var myPicturesPath = "C:\\_MedData\\_MedTemp\\";
        list.AddRange(Directory.GetFiles(myPicturesPath, "*.jpg", SearchOption.AllDirectories));
        if (list.Count == 0)
          {
          list.AddRange(Directory.GetFiles(commonPicturesPath, "*.png", SearchOption.AllDirectories));
          }
        }

      return list.ToArray();
      }

    private BitmapImage LoadPicture(int index)
      {
      BitmapImage value;

      if (this.picturePaths.Length != 0)
        {
        var actualIndex = index % this.picturePaths.Length;
        if (actualIndex < 0)
          {
          actualIndex += this.picturePaths.Length;
          }

        Debug.Assert(0 <= actualIndex, "Index used will be non-negative");
        Debug.Assert(actualIndex < this.picturePaths.Length, "Index is within bounds of path array");

        try
          {
          value = new BitmapImage(new Uri(this.picturePaths[actualIndex]));
          }
        catch (NotSupportedException)
          {
          value = null;
          }
        }
      else
        {
        value = null;
        }

      return value;
      }

    /// <summary>
    /// Create a wired-up recognizer for running the slideshow.
    /// </summary>
    /// <returns>The wired-up recognizer.</returns>
    private Recognizer CreateRecognizer()
      {
      // Instantiate a recognizer.
      var recognizer = new Recognizer();

      // Wire-up swipe right to manually advance picture.
      recognizer.SwipeRightDetected += (s, e) =>
      {
        if (e.Skeleton.TrackingId == nearestId)
          {
          Index++;

          // Setup corresponding picture if pictures are available.
          this.PreviousPicture = this.Picture;
          this.Picture = this.NextPicture;
          this.NextPicture = LoadPicture(Index + 1);

          // Notify world of change to Index and Picture.
          if (this.PropertyChanged != null)
            {
            this.PropertyChanged(this, new PropertyChangedEventArgs("PreviousPicture"));
            this.PropertyChanged(this, new PropertyChangedEventArgs("Picture"));
            this.PropertyChanged(this, new PropertyChangedEventArgs("NextPicture"));
            }

          var storyboard = Resources["LeftAnimate"] as Storyboard;
          if (storyboard != null)
            {
            storyboard.Begin();
            }

          HighlightSkeleton(e.Skeleton);
          }
      };

      // Wire-up swipe left to manually reverse picture.
      recognizer.SwipeLeftDetected += (s, e) =>
      {
        if (e.Skeleton.TrackingId == nearestId)
          {
          Index--;

          // Setup corresponding picture if pictures are available.
          this.NextPicture = this.Picture;
          this.Picture = this.PreviousPicture;
          this.PreviousPicture = LoadPicture(Index - 1);

          // Notify world of change to Index and Picture.
          if (this.PropertyChanged != null)
            {
            this.PropertyChanged(this, new PropertyChangedEventArgs("PreviousPicture"));
            this.PropertyChanged(this, new PropertyChangedEventArgs("Picture"));
            this.PropertyChanged(this, new PropertyChangedEventArgs("NextPicture"));
            }

          var storyboard = Resources["RightAnimate"] as Storyboard;
          if (storyboard != null)
            {
            storyboard.Begin();
            }

          HighlightSkeleton(e.Skeleton);
          }
      };

      return recognizer;
      }

    /// <summary>
    /// Handle insertion of Kinect sensor.
    /// </summary>
    private void InitializeNui()
      {
      this.UninitializeNui();

      var index = 0;
      while (this.nui == null && index < KinectSensor.KinectSensors.Count)
        {
        try
          {
          this.nui = KinectSensor.KinectSensors[index];

          this.nui.Start();

          this.IsDisconnected = false;
          this.DisconnectedReason = null;
          }
        catch (IOException ex)
          {
          this.nui = null;

          this.DisconnectedReason = ex.Message;
          }
        catch (InvalidOperationException ex)
          {
          this.nui = null;

          this.DisconnectedReason = ex.Message;
          }

        index++;
        }

      if (this.nui != null)
        {
        this.nui.SkeletonStream.Enable();

        this.nui.SkeletonFrameReady += this.OnSkeletonFrameReady;
        }
      }

    private void UninitializeNui()
      {
      if (this.nui != null)
        {
        this.nui.SkeletonFrameReady -= this.OnSkeletonFrameReady;

        this.nui.Stop();

        this.nui = null;
        }

      this.IsDisconnected = true;
      this.DisconnectedReason = null;
      }

    private void OnMainWindowLoaded(object sender, RoutedEventArgs e)
      {
      // Start the Kinect system, this will cause StatusChanged events to be queued.
      this.InitializeNui();

      // Handle StatusChange events to pick the first sensor that connects.
      KinectSensor.KinectSensors.StatusChanged += (s, ee) =>
      {
        switch (ee.Status)
          {
          case KinectStatus.Connected:
            if (nui == null)
              {
              Debug.WriteLine("New Kinect connected");

              InitializeNui();
              }
            else
              {
              Debug.WriteLine("Existing Kinect signalled connection");
              }

            break;
          default:
            if (ee.Sensor == nui)
              {
              Debug.WriteLine("Existing Kinect disconnected");

              UninitializeNui();
              }
            else
              {
              Debug.WriteLine("Other Kinect event occurred");
              }

            break;
          }
      };
      }

    private void OnSkeletonFrameReady(object sender, SkeletonFrameReadyEventArgs e)
      {
      // Get the frame.
      using (var frame = e.OpenSkeletonFrame())
        {
        // Ensure we have a frame.
        if (frame != null)
          {
          // Resize the skeletons array if a new size (normally only on first call).
          if (this.skeletons.Length != frame.SkeletonArrayLength)
            {
            this.skeletons = new Skeleton[frame.SkeletonArrayLength];
            }

          // Get the skeletons.
          frame.CopySkeletonDataTo(this.skeletons);

          // Assume no nearest skeleton and that the nearest skeleton is a long way away.
          var newNearestId = -1;
          var nearestDistance2 = double.MaxValue;

          // Look through the skeletons.
          foreach (var skeleton in this.skeletons)
            {
            // Only consider tracked skeletons.
            if (skeleton.TrackingState == SkeletonTrackingState.Tracked)
              {
              // Find the distance squared.
              var distance2 = (skeleton.Position.X * skeleton.Position.X) +
                  (skeleton.Position.Y * skeleton.Position.Y) +
                  (skeleton.Position.Z * skeleton.Position.Z);

              // Is the new distance squared closer than the nearest so far?
              if (distance2 < nearestDistance2)
                {
                // Use the new values.
                newNearestId = skeleton.TrackingId;
                nearestDistance2 = distance2;
                }
              }
            }

          if (this.nearestId != newNearestId)
            {
            this.nearestId = newNearestId;
            }

          // Pass skeletons to recognizer.
          this.activeRecognizer.Recognize(sender, frame, this.skeletons);

          this.DrawStickMen(this.skeletons);
          }
        }
      }

    private void HighlightSkeleton(Skeleton skeleton)
      {
      // Set the highlight time to be a short time from now.
      this.highlightTime = DateTime.UtcNow + TimeSpan.FromSeconds(0.5);

      // Record the ID of the skeleton.
      this.highlightId = skeleton.TrackingId;
      }


    private void DrawStickMen(Skeleton[] skeletons)
      {
      // Remove any previous skeletons.
      StickMen.Children.Clear();

      foreach (var skeleton in skeletons)
        {
        // Only draw tracked skeletons.
        if (skeleton.TrackingState == SkeletonTrackingState.Tracked)
          {
          // Draw a background for the next pass.
          this.DrawStickMan(skeleton, Brushes.WhiteSmoke, 7);
          }
        }

      foreach (var skeleton in skeletons)
        {
        // Only draw tracked skeletons.
        if (skeleton.TrackingState == SkeletonTrackingState.Tracked)
          {
          // Pick a brush, Red for a skeleton that has recently gestures, black for the nearest, gray otherwise.
          var brush = DateTime.UtcNow < this.highlightTime && skeleton.TrackingId == this.highlightId ? Brushes.Red :
              skeleton.TrackingId == this.nearestId ? Brushes.Black : Brushes.Gray;

          // Draw the individual skeleton.
          this.DrawStickMan(skeleton, brush, 3);
          }
        }
      }

    /// <summary>
    /// Draw an individual skeleton.
    /// </summary>
    /// <param name="skeleton">The skeleton to draw.</param>
    /// <param name="brush">The brush to use.</param>
    /// <param name="thickness">This thickness of the stroke.</param>
    private void DrawStickMan(Skeleton skeleton, Brush brush, int thickness)
      {
      Debug.Assert(skeleton.TrackingState == SkeletonTrackingState.Tracked, "The skeleton is being tracked.");

      foreach (var run in SkeletonSegmentRuns)
        {
        var next = this.GetJointPoint(skeleton, run[0]);
        for (var i = 1; i < run.Length; i++)
          {
          var prev = next;
          next = this.GetJointPoint(skeleton, run[i]);

          var line = new Line
          {
            Stroke = brush,
            StrokeThickness = thickness,
            X1 = prev.X,
            Y1 = prev.Y,
            X2 = next.X,
            Y2 = next.Y,
            StrokeEndLineCap = PenLineCap.Round,
            StrokeStartLineCap = PenLineCap.Round
          };

          StickMen.Children.Add(line);
          }
        }
      }

    /// <summary>
    /// Convert skeleton joint to a point on the StickMen canvas.
    /// </summary>
    /// <param name="skeleton">The skeleton.</param>
    /// <param name="jointType">The joint to project.</param>
    /// <returns>The projected point.</returns>
    private Point GetJointPoint(Skeleton skeleton, JointType jointType)
      {
      var joint = skeleton.Joints[jointType];

      // Points are centered on the StickMen canvas and scaled according to its height allowing
      // approximately +/- 1.5m from center line.
      var point = new Point
      {
        X = (StickMen.Width / 2) + (StickMen.Height * joint.Position.X / 3),
        Y = (StickMen.Width / 2) - (StickMen.Height * joint.Position.Y / 3)
      };

      return point;
      }
    }
  }
