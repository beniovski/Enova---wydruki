<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Kalend" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Core" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ Register TagPrefix="n0" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title></title>
		<script runat="server">


            private void repeater_BeforeRow(object sender, System.EventArgs e)
            {
                List<Wyplata> lw = (List<Wyplata>)repeater.CurrentRow;
                List<WypElement> elementy = new List<WypElement>();
                foreach (Wyplata w in lw)
                    foreach (WypElement we in w.ElementyWgKolejności)
                        elementy.Add(we);
                gridElements.DataSource = elementy;
            }

            void dc_OnContextLoad(Object sender, EventArgs args)
            {
                List<List<Wyplata>> wyplaty = new List<List<Wyplata>>();
                Row[] rows = (Row[])dc[typeof(Row[])];
                ArrayList al = new ArrayList();
                foreach (ListaPlac lista in rows)
                    al.Add(lista);


                foreach (ListaPlac lista in al)
                    foreach (Wyplata wp in lista.Wyplaty)
                    {
                        List<Wyplata> lw = new List<Wyplata>();
                        lw.Add(wp);
                        wyplaty.Add(lw);

                        foreach (List<Wyplata> l in wyplaty)
                        {
                            foreach (Wyplata w in l)
                            {
                                bool warunek = true;
                                if (w.Pracownik.Guid == wp.Pracownik.Guid &&  warunek && w.GetType() == wp.GetType())
                                {
                                    lw = l;
                                    break;
                                }
                            }

                        }
                        if (lw == null)
                        {
                            lw = new List<Wyplata>();
                            wyplaty.Add(lw);
                        }
                        lw.Add(wp);
                    }




                repeater.DataSource = wyplaty;
            }


            private string Korygowany(WypElement element)
            {
                string korektaTxt = " (korekta)";
                string depozytTxt = " (depozyt)";
                string nazwa = element.Nazwa;
                if (element.Definicja.Korygowany && nazwa.EndsWith(korektaTxt))
                    nazwa = nazwa.Replace(korektaTxt, "");
                else if (element is WypElementZajęcieKomornicze && nazwa.EndsWith(depozytTxt))
                    nazwa = nazwa.Replace(depozytTxt, "");
                return nazwa;
            }

            static readonly string prefix = "&nbsp;&nbsp;&nbsp;&nbsp;";

            private void gridElements_BeforeRow(object sender, Soneta.Web.RowEventArgs args)
            {
                WypElement element = (WypElement)args.Row;

                if (element.Wartosc == 0)
                    args.VisibleRow = true;
                else
                {
                    colNazwa.EditValue= element.Nazwa;
                    if (element.Nazwa == "Wynagrodzenie zasadnicze mies.")
                    {
                        colCzas.EditValue = element.Czas;
                        colDni.EditValue = element.Dni;

                    }
                    


                    WypSkladnikGłówny skg = element.SkładnikGłówny;
                    colProcent.AddLine(skg == null ? Percent.Zero : skg.Procent);
                    colCzas.EditValue = element.Czas;
                    //  colDni.EditValue = element.Dni;
                    AddWartosc(element.Wartosc);
                }


                foreach (WypSkladnik sk in element.Skladniki)
                {
                    //  test.EditValue = sk.Element.PracHistoria.Imie;
                    WypSkladnikGłówny skg = sk as WypSkladnikGłówny;
                    // test.EditValue = skg.Caption;
                    if (skg != null)
                    {
                        //  colNazwa.EditValue = element.PracHistoria.Imie +" "+ element.PracHistoria.Nazwisko;
                        colCzas.EditValue = skg.Czas;
                        colDni.EditValue = skg.Dni;

                        /*  colProcent.AddLine(skg.Procent);
                          colCzas.AddLine(skg.Czas);
                          colDni.AddLine(skg.Dni);
                          AddWartosc(skg.Wartosc);*/
                    }
                    else
                    {
                        WypSkladnikPomniejszenie skp = sk as WypSkladnikPomniejszenie;
                        colNazwa.EditValue = prefix+skp.Caption;

                        if (skp != null)
                        {
                            if (skp.Nieobecnosc.Definicja.Nazwa == "Zwolnienie chorobowe")
                                Chorobowe.EditValue = skp.Nieobecnosc.Dni;
                            colNazwa.EditValue =  skp.Nieobecnosc.Definicja.Nazwa;


                            /* colProcent.AddLine(skp.Procent);
                             colCzas.AddLine(skp.Czas);
                             colDni.AddLine(skp.Dni);
                             colDodatek.AddLine(skp.Wartosc);
                             colPotracenie.AddLine(0m);*/
                        }
                        else
                        {
                            colNazwa.EditValue = sk.Rodzaj;
                            /*  colProcent.AddLine(sk.Procent);
                              colCzas.AddLine(sk.Czas);
                              colDni.AddLine(sk.Dni);
                              colDodatek.AddLine(sk.Wartosc);
                              colPotracenie.AddLine(0m); */
                        }
                    }
                }
            }

            void AddWartosc(decimal v)
            {
                if (v >= 0)
                {
                    colDodatek.EditValue=v;

                }
                else
                {

                    colPotracenie.EditValue=-v;

                }
            }






        </script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
		<form id=form method=post runat="server"><ea:datacontext id="dc" runat="server" oncontextload="dc_OnContextLoad" TypeName="Soneta.KadryPlace"
					LeftMargin="-1" RightMargin="-1"></ea:datacontext><ea:datarepeater id="repeater" runat="server" Height="294px" Width="875px" RowTypeName="Soneta.Place.WyplataEtat,Soneta.KadryPlace"
						onbeforerow="repeater_BeforeRow" WithSections="false">
			               	    
                    
					
					<ea:Grid id="gridElements" runat="server" WithSections="False" onbeforerow="gridElements_BeforeRow" DataMember="ElementyWgKolejności">
						<Columns>
							<ea:GridColumn runat="server" Width="4" BottomBorder="None" Align="Right" DataMember="#" Caption="L.p." VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn runat="server" BottomBorder="None" Total="Info" ID="colNazwa" NoWrap="True" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn runat="server" Width="10" BottomBorder="None" Align="Right" Caption="Procent" HideZero="True" ID="colProcent" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn runat="server" Width="10" BottomBorder="None" Align="Right" Caption="Czas" HideZero="True" ID="colCzas" VAlign="Top" CssClass="c0"></ea:GridColumn>
					     
                            <ea:GridColumn runat="server" Width="10" BottomBorder="None" Align="Right" Caption="Dni" HideZero="True" ID="colDni" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn runat="server" Width="10" BottomBorder="None" Align="Right" Caption="Chorobowe" HideZero="True" ID="Chorobowe" VAlign="Top" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn runat="server" Width="15" BottomBorder="None" Align="Right" Total="Sum" Caption="Dodatek" HideZero="True" Format="{0:n}" ID="colDodatek" VAlign="Top" CssClass="c0"></ea:GridColumn>
							<ea:GridColumn runat="server" Width="15" BottomBorder="None" Align="Right" Total="Sum" Caption="Potrącenie" HideZero="True" Format="{0:n}" ID="colPotracenie" VAlign="Top" CssClass="c0"></ea:GridColumn>
                            <ea:GridColumn runat="server" Width="15" BottomBorder="None" Align="Right" Total="Sum" Caption="test" HideZero="True" Format="{0:n}" ID="test" VAlign="Top" CssClass="c0"></ea:GridColumn>
						</Columns>
					</ea:Grid>
					
				</ea:datarepeater> 
</form>
		
	</body>
</HTML>

