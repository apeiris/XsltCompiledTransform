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

                if (dialog.ShowDialog()==DialogResult.OK)
                {
                    Properties.Settings.Default.filePath = Properties.Settings.Default.filePath==string.Empty ? AppContext.BaseDirectory : Properties.Settings.Default.filePath; ;
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
            lblXslt.Text = Properties.Settings.Default.xsltFile==string.Empty?" ?": Properties.Settings.Default.xsltFile;
            lblXml.Text = Properties.Settings.Default.xmlFile== string.Empty ? " ?" : Properties.Settings.Default.xmlFile;
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
            txtOutput.Text = result.XdmNode.OuterXml;
            webBrowser1.Navigate("about:blank");
            if(webBrowser1.Document!=null)
            {
                webBrowser1.Document.Write(string.Empty);

            }
            webBrowser1.DocumentText = txtOutput.Text;
        }

     

        private void btnClear_Click(object sender, EventArgs e)
        {
            Debug.WriteLine(tabControl1.SelectedTab.Name);
           switch(tabControl1.SelectedTab.Name)
            {
                case "tabPage1":
                    txtOutput.Text = "";
                    Debug.WriteLine(tabControl1.SelectedTab.Name);
                    break;
                case "tabPage2":
                    Debug.WriteLine("Hi");
                    break;
                default:break;
            }
        }

       
    }
}
