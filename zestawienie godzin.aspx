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
        decimal lacznieBr =0;

        decimal nieopod = 0;
        decimal opodat = 0;

        double czasCalkowity = 0;
        double urlopCzas = 0;

        colNazImie.EditValue = string.Format("<strong>{0}</strong> {1}",wypłata.PracHistoria.Nazwisko, wypłata.PracHistoria.Imie);


        foreach (WypElement element in wypłata.ElementyWgKolejności)
        {

            nieopod += element.NiePodlegaOpodatkowaniu;

            fp += element.Podatki.FP.Skladka;
            fpgsp += element.Podatki.FGSP.Skladka;
            emer += element.Podatki.Emerytalna.Firma;
            rent += element.Podatki.Rentowa.Firma;
            wypad += element.Podatki.Wypadkowa.Firma;

            // czasPfron += element.Czas;

            wynagrodzenieNetto.EditValue = element.Wyplata.Wartosc;

            lacznieBr += element.DoOpodatkowania;

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.Nocne)
            {
                noc20.EditValue = element.Czas.TotalHours;

            }

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.NadgodzinyI)
            {
                nad50.EditValue = element.Czas.TotalHours;

            }

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.NadgodzinyŚw)
            {
                nad200.EditValue = element.Czas.TotalHours;

            }

            if (element.RodzajZrodla == RodzajŹródłaWypłaty.NadgodzinyII)
            {
                nad100.EditValue = element.Czas.TotalHours;

            }

            if (element.Nazwa == "Wynagr.chorobowe")
            {
                KosztChorobowe += element.Wartosc;
            }

            if (element.Nazwa == "Premia")
            {
                Premia.EditValue =  element.Wartosc;

            }

            if(element.Nazwa == "Ekwiwalent za czas urlopu prac. tymcz.")
            {
                urlopWypKoszt += element.Wartosc;
            }

            if(element.Nazwa == "Wynagr.urlop wypoczynkowy")
            {
                urlopCzas += element.Dni*8 + element.Czas.TotalHours;
            }

            if (element.Nazwa == "Wynagrodzenie zasadnicze mies.")
            {
                czasCalkowity += element.Czas.TotalHours;
                faktGodziny += Convert.ToDecimal(element.Czas.TotalHours*stawkaPodst) ;
            }

            if (element.Nazwa == "Wynagrodzenie zasadnicze mies. (korekta)")
            {
                czasCalkowity += element.Czas.TotalHours;
                faktGodziny += Convert.ToDecimal(element.Czas.TotalHours*stawkaPodst) ;
            }
        }

        lacznieBrutto.EditValue = lacznieBr;
        ElOpod.EditValue = lacznieBr;

        if (KosztChorobowe != 0)
            ChoroboweWynagrodzenie.EditValue = KosztChorobowe;

        if(KosztChorobowe==0)
            ChoroboweWynagrodzenie.EditValue = null;

        if(urlopWypKoszt!=0)
            urlopKoszt.EditValue = urlopWypKoszt;

        if (urlopWypKoszt == 0)
            urlopKoszt.EditValue = null;

        if (urlopCzas == 0)
            GodzinyUrlop.EditValue = null;

        if(urlopCzas!=0)
            GodzinyUrlop.EditValue = urlopCzas;

        if (nieopod != 0)
            ElNopod.EditValue = -nieopod;

        if(nieopod==0)
            ElNopod.EditValue = null;



        DniPracy.EditValue = czasCalkowity;
        GodzinyUrlop.EditValue = urlopCzas;
        ElNopod.EditValue = -nieopod;

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
<DIV align=center><STRONG><FONT size=6>ZESTAWIENIE PRZEPRACOWANYCH GODZIN 
</FONT></STRONG></DIV>
<DIV align=center>&nbsp;</DIV>
<DIV align=center>&nbsp;</DIV>
<DIV align=center><ea:Grid id="Grid" runat="server" onafterrender="Grid_AfterRender" onbeforerow="Grid_BeforeRow"	DataMember="Wyplaty" RowTypeName="Soneta.Place.Wyplata, Soneta.KadryPlace">
				<Columns>
					
                    <ea:GridColumn Width="2" Align="Center" DataMember="#" Caption="Lp" VAlign="Top" runat="server"></ea:GridColumn>
					<ea:GridColumn Width="25" Caption="Nazwisko i imię" Total="Info"  ID="colNazImie" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum" Caption="Wypłata netto" ID="wynagrodzenieNetto" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum" Caption="Godziny przepracowane" ID="DniPracy" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center"  Total ="Sum"  Caption="Urlop" ID="GodzinyUrlop" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Nadgodziny 50%" ID="nad50" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"   Caption="Nadgodziny 100%" ID="nad100" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Nadgodziny 200%" ID="nad200" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Godziny nocne 20%" ID="noc20" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Premia" ID="Premia" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Wynagrodzenie Chorobowe" ID="ChoroboweWynagrodzenie" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Ekwiwalent za urlop" ID="urlopKoszt" runat="server"></ea:GridColumn>                  
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Elementy opodatkowanie" ID="ElOpod" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Elementy nieopodatkowane" ID="ElNopod" runat="server"></ea:GridColumn>
                    <ea:GridColumn Width="10" Align="Center" Total ="Sum"  Caption="Łącznie brutto" ID="lacznieBrutto" runat="server"></ea:GridColumn>
                 
                    
                   
					
				</Columns>
			</ea:Grid></DIV></FORM></BODY></HTML>
