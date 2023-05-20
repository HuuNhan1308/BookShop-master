using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using BookShopManagement.BS_Layer;

namespace BookShopManagement.UserControls
{
    public partial class UC_ViewSales : UserControl
    {
        BL_WareHouse WareHouseDB = new BL_WareHouse();

        public UC_ViewSales()
        {
            InitializeComponent();
        }

        private void UC_ViewSales_Load(object sender, EventArgs e)
        {
            this.dgv_Warehouse.DataSource = null;

            this.dgv_Warehouse.DataSource = WareHouseDB.GetWareHouses_View();
        }
    }
}
