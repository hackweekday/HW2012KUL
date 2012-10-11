using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;

using Dicom;
using Dicom.Imaging;
using Dicom.IO.Buffer;

namespace DicomWave
{
    public partial class MainWindow : Window
    {
        private string _filePath;
        private int _numOfRow = 0;
        private DicomFile dcmFile;

        public MainWindow()
          {
          InitializeComponent();
          }

        private void OnClickLoadCase(object sender, RoutedEventArgs e)
          {
            Microsoft.Win32.OpenFileDialog dlg = new Microsoft.Win32.OpenFileDialog();
            dlg.FileName = "*.*"; // Default file name 
            dlg.DefaultExt = ".*"; // Default file extension. Because sometimes DICOM = *.vtk, *.dcm, *.1...n, no standard. 

            System.Windows.Forms.FolderBrowserDialog fb = new System.Windows.Forms.FolderBrowserDialog();
            fb.ShowDialog();
           
            try
              {
              BeginStoryboard((Storyboard)FindResource("rect_homeSB"));

                _filePath = fb.SelectedPath;
                DicomFile file = null;

                try
                  {
                  string[] filePaths = Directory.GetFiles(@_filePath);

                  file = DicomFile.Open(filePaths[0]); // terminator usually 1st or last of the series
                  dcmFile = file;
                  _UpdateCaseInformation(file);
                  var overviewImage = new DicomImage(filePaths[0]);
                  _DisplayOverviewImage(overviewImage);

                  //[fabhar - TODO] i know this is not a good pactice, but um.. 
                  //i cant think of something yet..

                  ThreadPool.QueueUserWorkItem(delegate(object s)
                  {
                  foreach (string filename in filePaths)
                    {
                    var image = new DicomImage(filename);
                    Directory.Delete("C:\\_MedData\\_MedTemp", true);
                    Directory.CreateDirectory("C:\\_MedData\\_MedTemp\\");
                    
                    image.RenderImage().Save("C:\\_MedData\\_MedTemp\\"+_numOfRow+"IMG"+".jpg");
                    this.Dispatcher.Invoke(new WaitCallback(_DisplayImage), image);
                    _numOfRow = _numOfRow + 1;
                    }
                  });

                  //[fabhar] reference for future implementation of _DisplayImage() MT operation.

                  //Thread thread1 = new Thread(new ThreadStart(A));
                  //thread1.Start();
                  //thread1.Join();
                  } 
                catch (DicomFileException ex)
                  {
                  file = ex.File;
                  MessageBox.Show(this, "Exception while loading DICOM file: " + ex.Message, "Error loading DICOM file");
                  }
            }
            catch (Exception ex)
              {
              MessageBox.Show(this, "Exception while loading DICOM file: " + ex.Message, "Error loading DICOM file");
              }
            finally
              {
              // end update here
              }
        }

        private void _UpdateCaseInformation(DicomFile file)
          {
          txt_HdrPatientName.Text = file.Dataset.Get<string>(DicomTag.PatientName);
          txt_HdrPatientID.Text = file.Dataset.Get<string>(DicomTag.PatientID);
          txt_PatientAge.Text = file.Dataset.Get<string>(DicomTag.PatientAge);
          txt_PatientSex.Text = file.Dataset.Get<string>(DicomTag.PatientSex);
          txt_Institution.Text = file.Dataset.Get<string>(DicomTag.InstitutionName);
          txt_ScanDate.Text = file.Dataset.Get<string>(DicomTag.Date);
          }

        protected void _DisplayImage(object state)
          {
          var image = (DicomImage)state;

          double scale = 1.0;
          Size max = this.RenderSize;

          int maxW = (int) (max.Width - (Width - ctr_Image.Width));
          int maxH = (int) (max.Height - (Height - ctr_Image.Height));

          System.Windows.Media.ImageSource WpfBitmap = _CalculateImage(image, ref scale, maxW, maxH);

          ctr_Image.Source = WpfBitmap;
          }

        protected void _DisplayOverviewImage(object state)
          {
          var image = (DicomImage)state;

          double scale = 1.0;
          Size max = this.RenderSize;

          int maxW = (int)(max.Width - (Width - ctr_Image_HDR.Width));
          int maxH = (int)(max.Height - (Height - ctr_Image_HDR.Height));

          System.Windows.Media.ImageSource WpfBitmap = _CalculateImage(image, ref scale, maxW, maxH);

          ctr_Image_HDR.Source = WpfBitmap;
          }

        private static System.Windows.Media.ImageSource _CalculateImage(DicomImage image, ref double scale, int maxW, int maxH)
          {
          if (image.Width > image.Height)
            {
            if (image.Width > maxW)
              scale = (double)maxW / (double)image.Width;
            }
          else
            {
            if (image.Height > maxH)
              scale = (double)maxH / (double)image.Height;
            }

          if (scale != 1.0)
            image.Scale = scale;

          //convert System.Drawing.Image to WPF image
          System.Drawing.Bitmap bmp = new System.Drawing.Bitmap(image.RenderImage());
          IntPtr hBitmap = bmp.GetHbitmap();
          System.Windows.Media.ImageSource WpfBitmap = System.Windows.Interop.Imaging.CreateBitmapSourceFromHBitmap(hBitmap, IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
          return WpfBitmap;
          }

        private void OnClickProceed(object sender, System.Windows.RoutedEventArgs e)
          {
          RevORWindow wnd = new RevORWindow();
          wnd.Initialise(dcmFile, _filePath);
          wnd.Show();

          this.Close();
          }

        private void OnClickORMode(object sender, System.Windows.RoutedEventArgs e)
        {
			try
			   {
        	// Due to dependency, it will be included in the same binaries folder
          Process startKinect = Process.Start("Slideshow.exe");
          this.Close();
          }
        catch (Exception)
          {
          Process startKinect = Process.Start("..\\..\\..\\GestureComponent\\bin\\Debug\\Slideshow.exe");
          this.Close();
          }
        finally
          {
          }        
		  }
    }
}
