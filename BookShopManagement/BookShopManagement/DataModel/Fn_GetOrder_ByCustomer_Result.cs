//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace BookShopManagement.DataModel
{
    using System;
    
    public partial class Fn_GetOrder_ByCustomer_Result
    {
        public Nullable<int> OrderID { get; set; }
        public string Name { get; set; }
        public Nullable<System.DateTime> Date { get; set; }
        public string Shipping_method { get; set; }
        public Nullable<double> Total_cost { get; set; }
        public Nullable<bool> Complete { get; set; }
    }
}
