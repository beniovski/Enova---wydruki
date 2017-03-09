<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Place" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="Soneta.Tools" %><%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Page Language="c#" CodePage="1200" %><HTML><HEAD><TITLE>Prosta lista płac</TITLE>
<SCRIPT runat="server">





    void Grid_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        Wyplata wypłata = (Wyplata)args.Row;

        double stawkaPodst=18.02;
        decimal KosztChorobowe = 0;
        decimal urlopWypKoszt = 0;
        decimal koszPoz = 0;
        decimal wypad = 0;
        decimal rent = 0;
        decimal emer=0;
        decimal fp = 0;
        decimal fpgsp = 0;
        decimal sumaFaktura =0;
        decimal kosztGodzin;
        decimal faktNoc = 0;
        decimal faktNad50 = 0;
        decimal faktNad100 = 0;
        decimal faktNad200 = 0;
        decimal faktPremia = 0;
        decimal faktGodziny= 0;

        Time czasPfron = new Time();
        colNazImie.EditValue = string.Format("<strong>{0}</strong> {1}",wypłata.PracHistoria.Nazwisko, wypłata.PracHistoria.Imie);


        foreach (WypElement element in wypłata.ElementyWgKolejności)
        {

            fp += element.Podatki.FP.Skladka;
            fpgsp += element.Podatki.FGSP.Skladka;
            emer += element.Podatki.Emerytalna.Firma;
            rent += element.Podatki.Rentowa.Firma;
            wypad += element.Podatki.Wypadkowa.Firma;
            czasPfron += element.Czas;

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.Nocne)
            {
                noc20.EditValue = element.Czas.TotalHours;
                faktNoc = Convert.ToDecimal(element.Czas.TotalHours *(stawkaPodst*0.200333)) ;
            }

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.NadgodzinyI)
            {
                nad50.EditValue = element.Czas.TotalHours;
                faktNad50 = Convert.ToDecimal(element.Czas.TotalHours *(stawkaPodst* 0.5)) ;
            }

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.NadgodzinyŚw)
            {
                nad200.EditValue = element.Czas.TotalHours;
                faktNad200 = Convert.ToDecimal(element.Czas.TotalHours *(stawkaPodst* 2));
            }

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.NadgodzinyII)
            {
                nad100.EditValue = element.Czas.TotalHours;
                faktNad100 = Convert.ToDecimal(element.Czas.TotalHours *(stawkaPodst* 1));
            }

            if (element.Nazwa == "Wynagr.chorobowe")
            {
                KosztChorobowe += element.Wartosc;
            }

            if (element.Nazwa == "Premia")
            {
                Premia.EditValue = decimal.Round(1.1m * 1.2074m * element.Wartosc, 2, MidpointRounding.AwayFromZero);
                faktPremia = Convert.ToDecimal(element.Wartosc * 1.1m * 1.2074m);
            }

            if(element.Nazwa == "Ekwiwalent za czas urlopu prac. tymcz.")
            {
                urlopWypKoszt += element.Wartosc;
            }


            if (element.Nazwa == "Wynagrodzenie zasadnicze mies.")
            {
                DniPracy.EditValue = element.Czas.TotalHours;
                faktGodziny = Convert.ToDecimal(element.Czas.TotalHours*stawkaPodst) ;
            }
        }
        if(KosztChorobowe!=0)
            ChoroboweWynagrodzenie.EditValue =  decimal.Round(  1.1m*KosztChorobowe, 2, MidpointRounding.AwayFromZero);

        if(KosztChorobowe==0)
            ChoroboweWynagrodzenie.EditValue = null;


      

        kosztGodzin = faktGodziny + faktNad200 + faktNad100 + faktNad50 + faktNoc ;
        sumaFaktura = kosztGodzin + faktPremia +  KosztChorobowe*1.1m + urlopWypKoszt*1.1m*1.2074m;

        suma.EditValue = decimal.Round(sumaFaktura, 2, MidpointRounding.AwayFromZero);
        godzinyKoszt.EditValue = decimal.Round(kosztGodzin, 2, MidpointRounding.AwayFromZero);

        if(urlopWypKoszt!=0)
            urlopKoszt.EditValue = decimal.Round( 1.1m*1.2074m*urlopWypKoszt, 2, MidpointRounding.AwayFromZero);

        if (urlopWypKoszt == 0)
            urlopKoszt.EditValue = null;

        /*   if (koszPoz != 0)
               pozostaleKoszty.EditValue = koszPoz;
           if (koszPoz == 0)
               pozostaleKoszty.EditValue = null;

           */

    }

    void Grid_AfterRender(object sender, System.EventArgs e)
    {
    }

    void dc_ContextLoad(Object sender, EventArgs e)
    {
        ListaPlac lista = (ListaPlac)dc[typeof(ListaPlac)];
    }

    static void Msg(object value)
    {
    }

		</SCRIPT>

<META content="text/html; charset=unicode" http-equiv=Content-Type>
<META name=GENERATOR content="Microsoft Visual Studio 7.0">
<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM id=ProstaListaPłac method=post runat="server"><ea:DataContext runat="server" ID="dc" LeftMargin="-1" PageSize="" RightMargin="-1" Landscape="True" TypeName="Soneta.Place.ListaPlac,Soneta.KadryPlace"></ea:DataContext>
<DIV align=center><STRONG><FONT size=6>PARETTi - Załącznik do faktury 
VAT/OP/10/01/2017</FONT></STRONG></DIV>
<DIV align=center>&nbsp;</DIV>
<DIV align=center>&nbsp;</DIV>
<DIV align=center><ea:Grid id="Grid" runat="server" onafterrender="Grid_AfterRender" onbeforerow="Grid_BeforeRow"	DataMember="Wyplaty" RowTypeName="Soneta.Place.Wyplata, Soneta.KadryPlace">
				<Columns>
					
                    <ea:GridColumn Width="4" Align="Center" DataMember="Numer.Numer" Caption="Lp" VAlign="Top" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="25" Caption="Nazwisko i imię" Total="Info"  ID="colNazImie" runat="server"></ea:GridColumn>
                   
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum" Caption="Godziny przepracowane" ID="DniPracy" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Nadgodziny 50%" ID="nad50" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"   Caption="Nadgodziny 100%" ID="nad100" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Nadgodziny 200%" ID="nad200" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Godziny nocne 20%" ID="noc20" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Right" Total ="Sum"  Caption="Godziny łącznie" ID="godzinyKoszt" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Premia" ID="Premia" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Wynagrodzenie Chorobowe" ID="ChoroboweWynagrodzenie" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Ekwiwalent za urlop" ID="urlopKoszt" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Inne" ID="pozostaleKoszty" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Right" FontBold="true" Total ="Sum"  Caption="Kwota do faktury VAT" ID="suma" runat="server"></ea:GridColumn>
                    
                   
					
				</Columns>
			</ea:Grid></DIV></FORM></BODY></HTML>
