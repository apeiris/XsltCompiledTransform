using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Saxon.Api;
using System.IO;
using System.Xml;
using System.Net;
using System.Diagnostics;
using System.Net.Http;

namespace XsltCompiledTransform
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void tabPage1_Click(object sender, EventArgs e)
        {

        }
        private string getFileName()
        {
            using (var dialog = new OpenFileDialog())
            {
                dialog.InitialDirectory = Properties.Settings.Default.filePath;
                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    Properties.Settings.Default.xmlFile = dialog.FileName;
                    return dialog.FileName;
                }
                return string.Empty;
            }
        }
        private void btnSetPath_Click(object sender, EventArgs e)
        {
            using (var dialog = new FolderBrowserDialog())
            {
                dialog.SelectedPath = Properties.Settings.Default.filePath == string.Empty ? AppContext.BaseDirectory : Properties.Settings.Default.filePath; ;

                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    Properties.Settings.Default.filePath = Properties.Settings.Default.filePath == string.Empty ? AppContext.BaseDirectory : Properties.Settings.Default.filePath; ;
                    Properties.Settings.Default.Save();
                }
            }
        }
        private void lblXml_Click(object sender, EventArgs e)
        {
            lblXml.Text = getFileName();
            Properties.Settings.Default.xmlFile = lblXml.Text;
            Properties.Settings.Default.Save();
        }
        private void lblXslt_Click(object sender, EventArgs e)
        {
            Debug.WriteLine(AppContext.BaseDirectory);
            lblXslt.Text = getFileName();
            Properties.Settings.Default.xsltFile = lblXslt.Text;
            Properties.Settings.Default.Save();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            lblXslt.Text = Properties.Settings.Default.xsltFile == string.Empty ? " ?" : Properties.Settings.Default.xsltFile;
            lblXml.Text = Properties.Settings.Default.xmlFile == string.Empty ? " ?" : Properties.Settings.Default.xmlFile;
            txtPostToUrl.Text = Properties.Settings.Default.post_to_url == string.Empty ? " ?" : Properties.Settings.Default.post_to_url;
            txtPostToUrl.Enabled = false;
        }
        private void btnTransform_Click(object sender, EventArgs e)
        {

            Processor processor = new Processor();
            DocumentBuilder builder = processor.NewDocumentBuilder();
            builder.BaseUri = new Uri(lblXml.Text);
            XdmNode input = builder.Build(File.OpenRead(lblXml.Text));
            XsltCompiler compiler = processor.NewXsltCompiler();
            compiler.BaseUri = new Uri(lblXslt.Text);
            Xslt30Transformer transformer = compiler.Compile(File.OpenRead(lblXslt.Text)).Load30();
            transformer.GlobalContextItem = input;
            Serializer serializer = processor.NewSerializer();

            XdmDestination result = new XdmDestination();


            serializer.SetOutputWriter(Console.Out);


            transformer.ApplyTemplates(input, result);
            Debug.WriteLine(input.OuterXml);

            txtOutput.Text = result.XdmNode.OuterXml;

            var path = Path.GetTempPath();
            var filename = Guid.NewGuid().ToString() + ".xml";
            var pName = Path.Combine(path, filename);
            File.WriteAllText(pName, txtOutput.Text);
            path = Path.Combine(Path.GetDirectoryName(lblXml.Text), Path.GetFileName(lblXml.Text).Replace(".dev", ".PRINT"));

            File.WriteAllText(path, txtOutput.Text);

            webBrowser1.Navigate(pName);

        }
        private void btnClear_Click(object sender, EventArgs e)
        {
            Debug.WriteLine(tabControl1.SelectedTab.Name);
            switch (tabControl1.SelectedTab.Name)
            {
                case "tabPage1":
                    txtOutput.Text = "";
                    Debug.WriteLine(tabControl1.SelectedTab.Name);
                    break;
                case "tabPage2":
                    Debug.WriteLine("Hi");
                    break;
                default: break;
            }
        }



        private static void SendWebRequest(HttpWebRequest http, byte[] fileData)
        {
            Stream oRequestStream = http.GetRequestStream();
            oRequestStream.Write(fileData, 0, fileData.Length);
            oRequestStream.Flush();
            oRequestStream.Close();
        }

      



        private static HttpStatusCode HandleWebResponse(HttpWebRequest http)
        {
            HttpWebResponse response = null;
            HttpStatusCode r;
            try
            {
                response = (HttpWebResponse)http.GetResponse();
                r = response.StatusCode;
                response.Close();

            }
            catch (Exception ex)
            {
                if (response != null)
                {
                    r = response.StatusCode;
                    Debug.WriteLine($"Exception:{ex.Message}\n {ex.StackTrace}");

                }
                else r = 0;
            }
            return r;
        }

        private async Task<System.IO.Stream> UploadAsync(string url, string filename, Stream fileStream)
        {
            // Convert each of the three inputs into HttpContent objects

            HttpContent stringContent = new StringContent(filename);
            // examples of converting both Stream and byte [] to HttpContent objects
            // representing input type file
            HttpContent fileStreamContent = new StreamContent(fileStream);




            using (var client = new HttpClient())
            {
                
                using (var formData = new MultipartFormDataContent())
                {
                    // Add the HttpContent objects to the form data

                    // <input type="text" name="filename" />
                    formData.Add(stringContent, "name", "AP_AccountStmt.xslt");
                    // <input type="file" name="file1" />
                    formData.Add(fileStreamContent, "file", "AP_AccountStatement.xslt");
                    formData.Add(stringContent,"Content-Length", "24328");
                    // <input type="file" name="file2" />
                    client.DefaultRequestHeaders.Add("ClientSystemId", "00D1y0000008jqPEAQ");
                    client.DefaultRequestHeaders.Add("AccessToken", "ZGka8PZdzah2mGK7M3eeqRYN7OejMNla");
                    client.DefaultRequestHeaders.Add("Accept", "*/*");
                    client.DefaultRequestHeaders.Add("Postman-Token", "70b07da1-67b4-4eb7-8755-7689e8f41fa1");
                    client.DefaultRequestHeaders.Add("Host", "real-time-apt-new-template.herokuapp.com");
                    client.DefaultRequestHeaders.Add("Connection", "keep-alive");
                    client.DefaultRequestHeaders.Add("Accept-Encoding", "gzip, deflate, br");
                  
                    //client.DefaultRequestHeaders.Add("Content-Length", "24328");
                    // Invoke the request to the server

                    // equivalent to pressing the submit button on
                    // a form with attributes (action="{url}" method="post")
                    var response = client.PostAsync(url, formData).Result;

                    // ensure the request was a success
                    if (!response.IsSuccessStatusCode)
                    {
                        return null;
                    }
                    return await response.Content.ReadAsStreamAsync();
                }
            }
        }

        private void btnPost_Click(object sender, EventArgs e)
        {
            Uri uri = new Uri(@"https://real-time-apt-new-template.herokuapp.com/ut/xslt/upload");
            using (FileStream fstream = File.Open(lblXslt.Text, FileMode.Open))
            {
                var x = UploadAsync(uri.ToString(), "Ap", fstream).Result;

            }


            
         



        }
    }
}
