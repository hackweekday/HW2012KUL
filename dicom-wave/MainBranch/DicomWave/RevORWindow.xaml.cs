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
using System.Windows.Media.Imaging;
using System.Windows.Navigation;

using Dicom;
using Dicom.Imaging;
using Dicom.IO.Buffer;

namespace DicomWave
{
    public partial class RevORWindow : Window
    {
        private string _filePath;
        private int _numOfRow = 0;
        private List<UIElement> _dicomPreview = new List<UIElement>();
        private Grid _dynamic_grid;

        public RevORWindow()
          {
          InitializeComponent();
          _InitDICOMPreview();
          }

        public void Initialise(DicomFile dcmFile, String filePath)
          {
          _filePath = filePath;
          DicomFile file = null;

          file = dcmFile;
          _UpdateInfo(file);

          try
            {
            string[] filePaths = Directory.GetFiles(@_filePath);

            ThreadPool.QueueUserWorkItem(delegate(object s)
              {
                foreach (string filename in filePaths)
                  {
                  var image = new DicomImage(filename);
                  this.Dispatcher.BeginInvoke(new WaitCallback(_DisplayImage), image);
                  _numOfRow = _numOfRow + 1;
                  }
              });
            }
          catch (DicomFileException ex)
            {
            file = ex.File;
            MessageBox.Show(this, "Exception while loading DICOM file: " + ex.Message, "Error loading DICOM file");
            }
          }

        private void _UpdateInfo(DicomFile file)
          {
          txt_HdrPatientName_RV.Text = file.Dataset.Get<string>(DicomTag.PatientName);
          txt_HdrPatientID_RV.Text = file.Dataset.Get<string>(DicomTag.PatientID);
          txt_PatientAge_RV.Text = file.Dataset.Get<string>(DicomTag.PatientAge);
          txt_PatientSex_RV.Text = file.Dataset.Get<string>(DicomTag.PatientSex);
          txt_Institution_RV.Text = file.Dataset.Get<string>(DicomTag.InstitutionName);
          txt_ScanDate_RV.Text = file.Dataset.Get<string>(DicomTag.Date);
          }

        protected void _DisplayImage(object state)
          {
          var image = (DicomImage)state;

          double scale = 1.0;
          Size max = this.RenderSize;

          int maxW = (int) (max.Width - (Width - ctr_Image_RV.Width));
          int maxH = (int)(max.Height - (Height - ctr_Image_RV.Height));

          System.Windows.Media.ImageSource WpfBitmap = _CalculateImage(image, ref scale, maxW, maxH);

          CreateDynamicWPFGrid(WpfBitmap);
          }

        private void CreateDynamicWPFGrid(System.Windows.Media.ImageSource bitmap)
          {
          Grid DynamicGrid = _dynamic_grid;
          
          // Create Rows
          RowDefinition gridRow1 = new RowDefinition();
          gridRow1.Height = new GridLength(bitmap.Height - 200);

          DynamicGrid.RowDefinitions.Add(gridRow1);

          // Add first column header
          Image imager = new Image();
          imager.Source = bitmap;

          Grid.SetRow(imager, _numOfRow);
          Grid.SetColumn(imager, 0);

          DynamicGrid.Children.Add(imager);
          }

        private void _InitDICOMPreview()
          {
          // Fill the Grid
          _dynamic_grid = dynamic_grid;

          // Create Columns
          ColumnDefinition gridCol1 = new ColumnDefinition();

          _dynamic_grid.ColumnDefinitions.Add(gridCol1);
          }

        protected void _DisplayOverviewImage(object state)
          {
          var image = (DicomImage)state;

          double scale = 1.0;
          Size max = this.RenderSize;

          int maxW = (int)(max.Width - (Width - ctr_Image_RV.Width));
          int maxH = (int)(max.Height - (Height - ctr_Image_RV.Height));

          System.Windows.Media.ImageSource WpfBitmap = _CalculateImage(image, ref scale, maxW, maxH);

          ctr_Image_RV.Source = WpfBitmap;
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
