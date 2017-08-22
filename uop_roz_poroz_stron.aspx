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
        [Caption("Data rozwiązania umowy")]
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



    void dc_ContextLoad(object sender, EventArgs e) {



        PracHistoria ph = (PracHistoria)dc[typeof(PracHistoria)];
        data.EditValue = DateTime.Now.ToString("yyyy-MM-dd");

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
content=http://schemas.microsoft.com/intellisense/ie5>
<STYLE type=text/css>
        .auto-style1 {
            margin-left: 40px;
        }
    .auto-style2 {
        font-weight: normal;
    }
    </STYLE>
</HEAD>
<BODY>
<FORM method=post runat="server"><ea:DataContext runat="server" ID="dc" OnContextLoad="dc_ContextLoad" TypeName="Soneta.Kadry.PracHistoria,Soneta.KadryPlace" RightMargin="-2" PageSize=""></ea:DataContext>
<P style="TEXT-ALIGN: right">Opole, <ea:DataLabel runat="server" EncodeHTML="True" ID="data"> </ea:DataLabel></P>
<P>&nbsp;</P>
<P></P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><FONT face="Times New Roman, serif"><FONT style="FONT-SIZE: 14pt" 
size=4><B>OŚWIADCZENIE O ROZWIĄZANIU UMOWY O PRACĘ 
TYMCZASOWĄ</B></FONT></FONT></P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><STRONG></STRONG>&nbsp;</P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align=center><STRONG></STRONG>&nbsp;</P>
<P class=western style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%" 
align="left"><FONT class=auto-style1 face="Times New Roman, serif"><FONT 
style="FONT-SIZE: 12pt" size=3>Strony zgodnie postanawiają że z dniem <FONT 
face="Times New Roman, serif"><ea:DataLabel runat="server" EncodeHTML="True" ID="dataZakonczenia"> </ea:DataLabel>&nbsp;ulega rozwiązaniu umowa 
o pracę tymczasową zawarta w dniu&nbsp;<ea:DataLabel runat=server DataMember="Etat.DataZawarcia" EncodeHTML="True"></ea:DataLabel> pomiędzy&nbsp; 
<STRONG>Paretti sp. z o.o. sp.k. z siedzibą w Opolu, ul. Oleska 7</STRONG> 
a&nbsp;&nbsp;<ea:DataLabel runat=server DataMember="Imie" EncodeHTML="True"></ea:DataLabel>&nbsp;<ea:DataLabel runat=server DataMember="Nazwisko" EncodeHTML="True"></ea:DataLabel>&nbsp;zamieszkałym(ą) <ea:DataLabel runat="server" EncodeHTML="True" ID="adres"> </ea:DataLabel>&nbsp; 
</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</FONT></FONT></P>
<P class=western 
style="MARGIN-BOTTOM: 0.28cm; LINE-HEIGHT: 108%; TEXT-INDENT: 1.25cm" 
align=justify><BR></P>
<P>&nbsp;</P>
    <div style="vertical-align:central">
<table >
<tr align="center">
    <th>_______________________</th>
    <th>_______________________</th>
</tr>
   
<tr align="center" style="font-size=9">
    <th class="auto-style2">(data, podpis pracownika)</th>
    <th class="auto-style2">(podpis pracodawcy lub osoby reprezentującej pracodawcę albo osoby<br />
&nbsp;upoważnionej do składania oświadczeń w imieniu pracodawcy)</th>
</tr>



</table>
        </div>




</FORM></BODY></HTML>
