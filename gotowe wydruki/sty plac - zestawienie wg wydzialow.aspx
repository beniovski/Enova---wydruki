<%@ Page Language="c#" autoeventwireup="false" CodePage="1200" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<script runat="server">
    
    class Sumator {
        readonly DefinicjaElementu definicja;
        readonly Wydzial wydzial;
        decimal wartosc;
        decimal fis;
        decimal zdrowotne;
        decimal doOdliczenia;
        decimal emerprac;
        decimal emerfirma;
        decimal rentprac;
        decimal rentfirma;
        decimal chor;
        decimal wyp;
        decimal fp;
        decimal fgsp;
        decimal fep;
        decimal dowyplaty;
    
        public Sumator(Wydzial wydzial, DefinicjaElementu definicja) {
            this.definicja = definicja;
            this.wydzial = wydzial;
        }
        public void Add(WypElement element) {
            wartosc += element.Wartosc;
            fis += element.Podatki.ZalFIS;
            zdrowotne += element.Podatki.Zdrowotna.Prac;
            doOdliczenia += element.Podatki.ZdrowotneDoOdliczenia;
            emerprac += element.Podatki.Emerytalna.Prac;
            emerfirma += element.Podatki.Emerytalna.Firma;
            rentprac += element.Podatki.Rentowa.Prac;
            rentfirma += element.Podatki.Rentowa.Firma;
            chor += element.Podatki.Chorobowa.Składka;
            wyp += element.Podatki.Wypadkowa.Składka;
            fp += element.Podatki.FP.Skladka;
            fgsp += element.Podatki.FGSP.Skladka;
            fep += element.Podatki.FEP.Skladka;
            dowyplaty += element.DoWypłaty;
        }
        public Wydzial Wydzial {
            get { return wydzial; }
        }
        public DefinicjaElementu Definicja {
            get { return definicja; }
        }
        public decimal Wartosc {
            get { return wartosc; }
        }
        public decimal FIS {
            get { return fis; }
        }
        public decimal Zdrowotna {
            get { return zdrowotne; }
        }
        public decimal DoOdliczenia {
            get { return doOdliczenia; }
        }
        public decimal EmerFirma {
            get { return emerfirma; }
        }
        public decimal EmerPrac {
            get { return emerprac; }
        }
        public decimal RentFirma {
            get { return rentfirma; }
        }
        public decimal RentPrac {
            get { return rentprac; }
        }
        public decimal Chor {
            get { return chor; }
        }
        public decimal Wyp {
            get { return wyp; }
        }
        public decimal FP {
            get { return fp; }
        }
        public decimal FGSP {
            get { return fgsp; }
        }
        public decimal FEP {
            get { return fep; }
        }
        public decimal DoWyplaty {
            get { return dowyplaty; }
        }
    }
    
    public class Params: ContextBase {
    
        public Params(Context context): base(context) {
        }
    
        bool opodatkowane = true;
        [Caption("Wynagr. opodatkowane")]
        [Priority(1)]
        public bool Opodatkowane {
            get { return opodatkowane; }
            set {
                opodatkowane = value;
                OnChanged(EventArgs.Empty);
            }
        }
    
        bool nieopodatkowane = true;
        [Caption("     nieopodatkowane")]
        [Priority(2)]
        public bool Nieopodatkowane {
            get { return nieopodatkowane; }
            set {
                nieopodatkowane = value;
                OnChanged(EventArgs.Empty);
            }
        }
    
        bool zasopodat = true;
        [Caption("Zasiłki opodatkowane")]
        [Priority(3)]
        public bool ZasOpodat {
            get { return zasopodat; }
            set {
                zasopodat = value;
                OnChanged(EventArgs.Empty);
            }
        }
    
        bool zasnieopodat = true;
        [Caption("     nieopodatkowane")]
        [Priority(4)]
        public bool ZasNieopodat {
            get { return zasnieopodat; }
            set {
                zasnieopodat = value;
                OnChanged(EventArgs.Empty);
            }
        }
    }

    public class SrParams : SerializableContextBase {
        public SrParams(Context context) : base(context) {
        }

        //Pole określa sposób wyliczania wydziału z elementu.
        //true - wydział jest odczytywany z listy płac do której należy element
        //false - wydział jest odczytywany z pola wydział w elemencie
        //static bool wydziałWgListyPłac = false;
        bool wydziałWgListyPłac = false;
        [Caption("Wydział wg listy płac")]
        [Priority(1)]
        public bool WydziałWgListyPłac {
            get { return wydziałWgListyPłac; }
            set {
                wydziałWgListyPłac = value;
                OnChanged(EventArgs.Empty);
            }
        }
    }
    
    Params pars;
    [Context]
    public Params Pars {
        get { return pars; }
        set { pars = value; }
    }

    SrParams srpars;
    [SettingsContext]
    public SrParams SrPars {
        get { return srpars; }
        set { srpars = value; }
    }
    
    bool Filter(WypElement element)
    {
        bool fis = element.Definicja.Info.Opodatkowany;
        bool zas = WypElement.Zasiłek.Eval(element);
    
        if (zas) {
            if (fis)
                return pars.ZasOpodat;
            return pars.ZasNieopodat;
        }
        else if (fis)
            return pars.Opodatkowane;
    
        return pars.Nieopodatkowane;
    }
    
    void InitHeader() {
        string s1 = "";
        if (pars.Opodatkowane && pars.Nieopodatkowane)
            s1 = "Wynagrodzenia";
        else if (pars.Opodatkowane)
            s1 = "Wynagrodzenia opodatkowane";
        else if (pars.Nieopodatkowane)
            s1 = "Wynagrodzenia nieopodatkowane";
    
        string s2 = "";
        if (pars.ZasOpodat && pars.ZasNieopodat)
            s2 = "Zasiłki";
        else if (pars.ZasOpodat)
            s2 = "Zasiłki opodatkowane";
        else if (pars.ZasNieopodat)
            s2 = "Zasiłki nieopodatkowane";
    
        if (s1=="")
            s1 = s2;
        else if (s2!="")
            s1 += "|" + s2;
    
        ReportHeader["INFO"] = s1;
    }

    Wydzial GetWydzial(WypElement element) {
        return srpars.WydziałWgListyPłac ? element.Wyplata.ListaPlac.Wydzial : element.Wydzial;
    }
    
    void dc_ContextLoad(Object sender, EventArgs e) {
        InitHeader();
    
        Hashtable ht = new Hashtable();
        string listy = "";
    
        Row[] rows = (Row[])dc[typeof(Row[])];
        foreach (ListaPlac lista in rows) {
            if (listy=="")
                listy = lista.Numer.NumerPelny;
            else
                listy += "; " + lista.Numer.NumerPelny;
            foreach (Wyplata wyplata in lista.Wyplaty)
                foreach (WypElement element in wyplata.Elementy)
                    if (Filter(element)) {
                        string key = element.Wydzial.Nazwa + "?" + element.Definicja.Nazwa;
                        Sumator sum = (Sumator)ht[key];
                        if (sum==null) {
                            sum = new Sumator(GetWydzial(element), element.Definicja);
                            ht.Add(key, sum);
                        }
                        sum.Add(element);
                    }
        }
    
        ArrayList keys = new ArrayList(ht.Keys);
        keys.Sort();
    
        ArrayList values = new ArrayList();
        foreach (string key in keys)
            values.Add(ht[key]);
    
        if (listy.Length>103)
            listy = listy.Substring(0, 100) + "...";
        Opis.EditValue = "<b>Listy płac: </b>" + listy;
    
        Grid1.DataSource = values;
    }

</script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<html>
<head>
    <title>Zestawienie wynagrodzeń wg wydziałów</title> 
    <meta content="C#" name="CODE_LANGUAGE" />
    <meta content="JavaScript" name="vs_defaultClientScript" />
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema" />
</head>
<body>
    <form method="post" runat="server">
        <ea:DataContext id="dc" runat="server" OnContextLoad="dc_ContextLoad"></ea:DataContext>
        <p>
            <eb:ReportHeader NagłówekOddziału="NagłówekOddziału" id="ReportHeader" title="Zestawienie wynagrodzeń wg wydziałów|%INFO%" runat="server"></eb:ReportHeader>
        </p>
        <p>
            <ea:DataLabel id="Opis" runat="server" Bold="False"></ea:DataLabel>
        </p>
        <ea:Grid id="Grid1" runat="server" RowsInRow="2" GroupData0="Wydzial.Nazwa" GroupLine="Wydział: {0}" ShowGroupSum="True">
            <Columns>
                <ea:GridColumn Width="30" DataMember="Definicja.Nazwa" Total="Info" Caption="Element wynagrodzenia" Format="{0}" NoWrap="True" RowSpan="2"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="Wartosc" Total="Sum" Caption="Suma wypłat" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="FIS" Total="Sum" Caption="Zal.podatku" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="Zdrowotna" Total="Sum" Caption="Zdrowotna" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="DoOdliczenia" Total="Sum" 
                    Caption="...do odlicz." HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="EmerPrac" Total="Sum" Caption="Emer.prac." HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="EmerFirma" Total="Sum" Caption="Emer.firma" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="RentPrac" Total="Sum" Caption="Rent.prac." HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="RentFirma" Total="Sum" Caption="Rent.firma." HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="Chor" Total="Sum" Caption="Chorobowa" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="Wyp" Total="Sum" Caption="Wypadkowa" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="FP" Total="Sum" Caption="FP" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="FGSP" Total="Sum" Caption="FGŚP" HideZero="True" Format="{0:n}"></ea:GridColumn>
                <ea:GridColumn Align="Right" Caption="FEP" DataMember="FEP" Format="{0:n}" 
                    HideZero="True" Total="Sum"></ea:GridColumn>
                <ea:GridColumn Align="Right" DataMember="DoWyplaty" Total="Sum" Caption="Do wypłaty" Format="{0:n}"></ea:GridColumn>
            </Columns>
        </ea:Grid>
        <eb:ReportFooter id="ReportFooter" runat="server" TheEnd="False"></eb:ReportFooter>
    </form>
</body>
</html>
