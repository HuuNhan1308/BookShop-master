﻿using BookShopManagement.Forms;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BookShopManagement.DataModel;
using BookShopManagement.UserControls;
using System.Reflection.Emit;
using BookShopManagement.Function;
using BookShopManagement.UserControls.Register;

namespace BookShopManagement
{
    public partial class Form1 : Form
    {


        public Form1()
        {
            InitializeComponent();
            panel2.Dock = DockStyle.Fill;
            panel2.Anchor = AnchorStyles.None;
            //panel2.Anchor = AnchorStyles.None;
            UC_Login ul = new UC_Login();
            AddControlsToPanel(ul);
            ul.ButtonClicked += Close;


        }

        private void Close(object sender, EventArgs e)
        {
            this.Hide();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        
        private void AddControlsToPanel(Control c)
        {
            c.Dock = DockStyle.Fill;
            c.Left = panel2.Size.Width / 2 - c.Width / 2;
            c.Top = panel2.Size.Height / 2 - c.Height / 2;
            panel2.Controls.Clear();
            panel2.Controls.Add(c);
        } 

        private bool log = true;
        private RegisterSession registerSession = null;
        private void label7_Click_1(object sender, EventArgs e)
        {
            if (log)
            {
                log = false;
                label7.Text = "Have account? Go login!";
                registerSession = new Function.RegisterSession();
                UC_Register ul = new UC_Register(registerSession); 
                ul.ButtonClicked += NextButtonClicked;
                AddControlsToPanel(ul); 
            }
            else
            {
                log = true;
                label7.Text = "Dont have account? Go register!";
                UC_Login ul = new UC_Login();
                AddControlsToPanel(ul);
                ul.ButtonClicked += Close;
            }
        }

        private void NextButtonClicked(object sender, EventArgs e)
        {
            if (registerSession != null)
            {
                switch (registerSession.Phase)
                {
                    case 1:
                        registerSession.Phase = 2;
                        UC_RegisterPhase2 ul2 = new UC_RegisterPhase2(registerSession);
                        ul2.ButtonClicked += NextButtonClicked;
                        AddControlsToPanel(ul2);
                        break;
                    case 2:
                        registerSession.Phase = 3;
                        UC_RegisterPhase3 ul3 = new UC_RegisterPhase3(registerSession);
                        AddControlsToPanel(ul3);
                        break;
                }
            }
        }
    }
}
