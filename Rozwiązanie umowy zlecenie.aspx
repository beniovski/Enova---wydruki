<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.Place" %><%@ import Namespace="Soneta.Kadry" %><%@ import Namespace="Soneta.KadryPlace" %><%@ import Namespace="Soneta.Core" %><%@ import Namespace="Soneta.Tools" %><%@ import Namespace="Soneta.Types" %><%@ import Namespace="Soneta.Kalend" %><%@ import Namespace="Soneta.Business" %><%@ import Namespace="System.ComponentModel" %><%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %><%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %><%@ Page language="c#" AutoEventWireup="false" codePage="1200" %><HTML><HEAD><TITLE>UmowaParetti</TITLE>
<SCRIPT runat="server">
    static int umowaID = 0;
    static int id;


    public class _Info : ContextBase
    {
        public _Info(Context context) : base(context)
        {
        }


        string dataZakonczenia ="";
        [Caption("Data rozwi¹zania umowy")]
        [Priority(10)]
        public string DataZak {
            get { return dataZakonczenia; }
            set {
                dataZakonczenia = value;
                OnChanged(EventArgs.Empty);
            }
        }



    }


    _Info info;
    [Context]
    public _Info Info {
        set { info = value; }
    }



    void dc_ContextLoading(object sender, EventArgs e) {
        try {
            if (Request.QueryString.Get("UmowaID") != string.Empty)
                umowaID = Convert.ToInt32(Request.QueryString.Get("UmowaID"));


        }

        catch { }
        if (umowaID != 0) {
            KadryModule km = KadryModule.GetInstance(dc);
            UmowaHistoria uh = km.UmowaHistorie[umowaID];


            if (uh != null) {
                dc.Context[typeof(UmowaHistoria)] = uh;
                dc.Context[typeof(Umowa)] = uh.Umowa;


            }
        }
    }

    void dc_ContextLoad(object sender, EventArgs e) {


        UmowaHistoria umowaHist = (UmowaHistoria)dc[typeof(UmowaHistoria)];
        Pracownik prac = (Pracownik)dc[typeof(Pracownik)];




        Umowa umowa = umowaHist.Umowa;
        PracHistoria ph = umowa.PracHistoria;
        Pracownik pr = umowa.Pracownik;

        data.EditValue = DateTime.Now.ToString("yyyy-MM-dd");
        dataZakonczenia.EditValue = info.DataZak;
        DanePracownika(ph);

    }

    void DanePracownika(PracHistoria ph)
    {
        string adresZameldowaniaUlica = ph.AdresZameldowania.Ulica;
        string adresZameldowaniaNrDomu = ph.AdresZameldowania.NrDomu;
        string adresZameldowaniaNrLokalu = " ";
        string adresZamelodwaniakodPocztowy = ph.AdresZameldowania.KodPocztowyS;
        string adresZameldowaniaMiejscowosc = ph.AdresZameldowania.Miejscowosc;



        string adresDoKorespondencjiUlica = ph.AdresZamieszkania.Ulica;
        string adresDoKorespondencjiNrDomu = ph.AdresZamieszkania.NrDomu;
        string adresDoKorespondencjiNrLokalu = " ";
        string adresDoKorespondencjikodPocztowy = ph.AdresZamieszkania.KodPocztowyS;
        string adresDoKorespondencjiMiejscowosc = ph.AdresZamieszkania.Miejscowosc;

        if(ph.AdresZamieszkania.NrLokalu!="")
        {
            adresDoKorespondencjiNrLokalu = "/"+ph.AdresZamieszkania.NrLokalu;
        }
        if(ph.AdresZameldowania.NrLokalu!="")
        {
            adresZameldowaniaNrLokalu = "/"+ph.AdresZameldowania.NrLokalu;
        }

        if(adresDoKorespondencjiMiejscowosc!="" || adresDoKorespondencjiUlica!="" || adresDoKorespondencjikodPocztowy!="" )
        {
            adres.EditValue = adresDoKorespondencjiUlica + " " +adresDoKorespondencjiNrDomu+adresDoKorespondencjiNrLokalu + ", " + adresDoKorespondencjikodPocztowy + " " + adresDoKorespondencjiMiejscowosc;
        }
        else
        {
            adres.EditValue = adresZameldowaniaUlica + " "+adresZameldowaniaNrDomu+adresZameldowaniaNrLokalu + ", " + adresZamelodwaniakodPocztowy + " " + adresZameldowaniaMiejscowosc;
        }

    }

</SCRIPT>

<META name=CODE_LANGUAGE content=C#>
<META name=vs_defaultClientScript content=JavaScript>
<META name=vs_targetSchema 
content=http://schemas.microsoft.com/intellisense/ie5></HEAD>
<BODY>
<FORM method=post runat="server"><ea:DataContext runat="server" OnContextLoading="dc_ContextLoading" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Kadry.Umowa,Soneta.KadryPlace" RightMargin="-2" PageSize="" ID="dc"></ea:DataContext>
<P style="TEXT-ALIGN: right">Opole, <ea:DataLabel runat="server" EncodeHTML="True" ID="data"> </ea:DataLabel></P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P></P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><FONT face="Times New Roman, serif"><FONT style="FONT-SIZE: 14pt" 
size=4><B>OŒWIADCZENIE O ROZWI¥ZANIU UMOWY ZLECENIA NA ZASADZIE POROZUMIENIA 
STRON</B></FONT></FONT></P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><STRONG></STRONG>&nbsp;</P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><STRONG></STRONG>&nbsp;</P>
<P></P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=justify><FONT face="Times New Roman, serif"><FONT style="FONT-SIZE: 12pt" 
size=3>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Strony 
zgodnie oœwiadczaj¹, i¿ rozwi¹zuj¹ umowê zlecenie nr <ea:DataLabel runat=server DataMember="Numer.Pelny" EncodeHTML="True"></ea:DataLabel>&nbsp;</FONT></FONT><FONT 
face="Times New Roman, serif"><FONT style="FONT-SIZE: 12pt" size=3>zawart¹ w 
dniu&nbsp;<ea:DataLabel runat=server DataMember="Last.Umowa.Data" EncodeHTML="True"></ea:DataLabel> &nbsp;pomiêdzy 
<STRONG>Paretti sp. z o.o. sp.k. z siedzib¹ w Opolu, ul. Oleska 7</STRONG> 
</FONT></FONT><FONT face="Times New Roman, serif"><FONT style="FONT-SIZE: 12pt" 
size=3>(zwan¹ dalej „Zleceniodawc¹”) a <ea:DataLabel runat=server DataMember="PracHistoria.Imie" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="PracHistoria.Nazwisko" EncodeHTML="True"></ea:DataLabel>&nbsp;zamieszka³y(a) 
<ea:DataLabel runat="server" EncodeHTML="True" ID="adres"> </ea:DataLabel>&nbsp;(zwanym dalej „Zleceniobiorc¹”) w 
przedmiocie wykonywania prac. </FONT></FONT><FONT 
face="Times New Roman, serif"><FONT style="FONT-SIZE: 12pt" size=3>Rozwi¹zanie 
umowy, o której wy¿ej mowa, nastêpuje z dniem  
<ea:DataLabel runat="server" EncodeHTML="True" ID="dataZakonczenia"> </ea:DataLabel>&nbsp;na zasadzie 
</FONT></FONT><FONT face="Times New Roman, serif"><FONT style="FONT-SIZE: 12pt" 
size=3>porozumienia stron. </FONT></FONT></P>
<P class=western 
style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%; TEXT-INDENT: 1.25cm" 
align=justify><BR><BR></P>
<P class=western 
style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%; TEXT-INDENT: 1.25cm" 
align=justify><FONT face="Times New Roman, serif"><FONT style="FONT-SIZE: 12pt" 
size=3>Niniejsze oœwiadczenie zosta³o sporz¹dzone w dwóch jednobrzmi¹cych 
egzemplarzach, po jednym dla ka¿dej ze stron.</FONT></FONT></P>
<P></P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>&nbsp;</P>
<P>Podpis Zleceniodawcy _______________________ Podpis Zleceniobiorcy 
_______________________</P></FORM></BODY></HTML>
