<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Core" %>
<%@ import Namespace="Soneta.Kasa" %>
<%@ import Namespace="System.Collections.Generic" %>
<%@ Register TagPrefix="n0" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title></title>
		<script runat="server">

            static int WymaganaIlośćLinii = 28;
            static int MinimalnaIlośćLinii = 22;
            static int BazowaIlośćLinii = 13;    

            [DefaultWidth(20)]
            public enum ZakresDanych {
                Wszystkie, TylkoGotówką
            }

            public class Params : ContextBase {
                public Params(Context context)
                    : base(context) {
                }

                ZakresDanych zakres = ZakresDanych.Wszystkie;
                [Caption("Drukuj wypłaty")]
                [Priority(1)]
                public ZakresDanych Zakres {
                    get { return zakres; }
                    set {
                        zakres = value;
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

            void dc_OnContextLoad(Object sender, EventArgs args) {
                ListaPlac lista = (ListaPlac)dc[typeof(ListaPlac)];
                if (pars.Zakres == ZakresDanych.Wszystkie)
                    repeater.DataSource = lista.Wyplaty;
                else {
                    ArrayList al = new ArrayList();
                    foreach (Soneta.Place.Wyplata w in lista.Wyplaty)
                        if (w.Gotówka != Currency.Zero)
                            al.Add(w);
                    repeater.DataSource = al;
                }

                //labelCopyright.EditValue = dc.Copyright;
            }

            int ilośćLinii;    
            private void repeater_BeforeRow(object sender, System.EventArgs e) {
                ilośćLinii = BazowaIlośćLinii;
                Soneta.Place.Wyplata wypłata = (Soneta.Place.Wyplata)repeater.CurrentRow;
                gridHeader.DataSource = new object[] { new ContextObject(wypłata, dc.Context) };
                gridElements.DataSource = new object[] { new ContextObject(wypłata, dc.Context) };
                gridKto.DataSource = new object[] { new ContextObject(wypłata, dc.Context) };
                gridStopka.DataSource = new object[] { new ContextObject(wypłata, dc.Context) };
            }

            private void gridHeader_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
                Soneta.Place.Wyplata wypłata = (Soneta.Place.Wyplata)ContextObject.GetOriginal(args.Row);
                Currency gotówka = new Currency(0m, wypłata.Wartosc.Symbol);
                List<Currency> rory = new List<Currency>();
                foreach (Platnosc płatność in wypłata.Platnosci) {
                    Currency kwota = płatność.Kierunek == KierunekPlatnosci.Rozchod ? płatność.Kwota : -płatność.Kwota;
                    if (płatność.SposobZaplaty.Typ == TypySposobowZaplaty.Gotówka)
                        gotówka += kwota;
                    else
                        rory.Add(kwota);
                }

                if (gotówka != 0m)
                    colRozliczenie.AddLine(string.Format("Gotówka:{0,16}", gotówka));
                int c = 0;
                foreach (Currency ror in rory)
                    colRozliczenie.AddLine(string.Format("ROR {0}:{1,18}", ++c, ror));
                if (c > 2)
                    ilośćLinii += c - 2;
            }

	        static readonly string prefix = "- ";
		    
            private void gridElements_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
                Soneta.Place.Wyplata wypłata = (Soneta.Place.Wyplata)ContextObject.GetOriginal(args.Row);
                int lp = 0;
                decimal kwotaOP = 0m;
                bool anyOP = false;
                decimal kwotaNO = 0;
                bool anyNO = false;
                foreach (WypElement element in wypłata.ElementyWgKolejności) {
                    DrukujElement(ref lp, element);
                    if (element.DoOpodatkowania != 0) {
                        kwotaOP += element.DoOpodatkowania;
                        anyOP = true;
                    }
                    if (element.NiePodlegaOpodatkowaniu != 0) {
                        kwotaNO += element.NiePodlegaOpodatkowaniu;
                        anyNO = true;
                    }
                }
                
                WyplataSkładkiWorker składki = new WyplataSkładkiWorker();
                składki.Wypłata = wypłata;
                DrukujSkładkę("E", składki.Razem.Emerytalna);
                DrukujSkładkę("R", składki.Razem.Rentowa);
                DrukujSkładkę("Ch", składki.Razem.Chorobowa);
                DrukujSkładkę("W", składki.Razem.Wypadkowa);
                DrukujSkładkę("RAZEM SKŁ. ZUS ",
                    składki.Razem.Emerytalna.Prac + składki.Razem.Rentowa.Prac + składki.Razem.Chorobowa.Prac/* + składki.Razem.Wypadkowa.Podstawa*/,
                    składki.Razem.Emerytalna.Firma + składki.Razem.Rentowa.Firma + składki.Razem.Chorobowa.Firma + składki.Razem.Wypadkowa.Firma);
                DrukujSkładkę("Z", składki.Razem.Zdrowotna);

                colPodstawy.AddLine("");
                colUbezpieczony.AddLine("");
                colPłatnik.AddLine("");
                colPodstawy.AddLine("Razem");
                colUbezpieczony.AddLine("Opodatkowane");
                colPłatnik.AddLine("Nieopodat.");
                colPodstawy.AddLine();
                colUbezpieczony.AddLine(kwotaOP);
                colPłatnik.AddLine(kwotaNO);
            }

            void DrukujSkładkę(string label, ISkładka składka) {
                string fs = "{0}:{1, " + (16 - label.Length - 1) + ":n}";
                DrukujSkładkę(string.Format(fs, label, składka.Podstawa), składka.Prac, składka.Firma);
            }

            void DrukujSkładkę(string label, decimal ubezpieczony, decimal płatnik) {
                colPodstawy.AddLine(label);
                colUbezpieczony.AddLine(ubezpieczony);
                colPłatnik.AddLine(płatnik);
            }
		            
            void DrukujSumę(string opis, decimal kwota) {
                colLp.AddLine(0);
                ilośćLinii++;
                colNazwa.AddLine(opis);
                colProcent.AddLine(Percent.Zero);
                colCzas.AddLine(Time.Zero);
                colDni.AddLine(0);
                colKwota.AddLine(kwota);
            }
		    
            void DrukujElement(ref int lp, WypElement element) {
                colLp.AddLine(++lp);
                ilośćLinii++;
                bool any = false;
                
                List<WypSkladnik> pozostałe = new List<WypSkladnik>();
                foreach (WypSkladnik sk in element.Skladniki) {
                    WypSkladnikGłówny skg = sk as WypSkladnikGłówny;
                    if (skg != null) {
                        colNazwa.AddLine(element.Nazwa);
                        colProcent.AddLine(skg.Procent);
                        colCzas.AddLine(skg.Czas);
                        colDni.AddLine(skg.Dni);
                        colKwota.AddLine(skg.Wartosc);
                        any = true;
                    }
                    else
                        pozostałe.Add(sk);
                }

                if (!any) {
                    colNazwa.AddLine(element.Nazwa);
                    colProcent.AddLine(Percent.Zero);
                    colCzas.AddLine(Time.Zero);
                    colDni.AddLine(0);
                    colKwota.AddLine(0.0m);
                }

                foreach (WypSkladnik sk in pozostałe) {
                    WypSkladnikPomniejszenie skp = sk as WypSkladnikPomniejszenie;
                    if (skp != null) {
                        colLp.AddLine(0);
                        ilośćLinii++;
                        colNazwa.AddLine(prefix + skp.Nieobecnosc.Definicja.Nazwa + " (" + skp.Okres + ")");
                        colProcent.AddLine(skp.Procent);
                        colCzas.AddLine(skp.Czas);
                        colDni.AddLine(skp.Dni);
                        colKwota.AddLine(skp.Wartosc);
                    }
                    else {
                        colLp.AddLine(0);
                        ilośćLinii++;
                        colNazwa.AddLine(prefix + CaptionAttribute.EnumToString(sk.Rodzaj));
                        colProcent.AddLine(sk.Procent);
                        colCzas.AddLine(sk.Czas);
                        colDni.AddLine(sk.Dni);
                        colKwota.AddLine(sk.Wartosc);
                    }
                }
            }

            protected void gridKto_BeforeRow(object sender, RowEventArgs args) {
                Soneta.Place.Wyplata wypłata = (Soneta.Place.Wyplata)ContextObject.GetOriginal(args.Row);
                int reszta = WymaganaIlośćLinii - System.Math.Max(MinimalnaIlośćLinii, ilośćLinii);
                if (reszta > 1) {
                    colWho.AddLine("Sporządził: " + dc.Session.Login.Operator.FullName);
                    colWho.AddLine("Data sporządzenia: " + dc.Session.Login.CurrentDate);
                    reszta--;
                }
                else
                    colWho.AddLine("Sporządził: " + dc.Session.Login.Operator.FullName + ", dnia: " + dc.Session.Login.CurrentDate);

                while (reszta-- > 0)
                    colWho.AddLine();
            }
		    
            protected void gridStopka_BeforeRow(object sender, RowEventArgs args) {
                Soneta.Place.Wyplata wypłata = (Soneta.Place.Wyplata)ContextObject.GetOriginal(args.Row);
                CoreModule core = CoreModule.GetInstance(wypłata);
                colFirma.AddLine("Nazwa firmy: " + core.Config.Firma.Pieczątka.NazwaSkrócona);
                colFirma.AddLine("NIP:         " + core.Config.Firma.Pieczątka.NIP);
                colFirma.AddLine("REGON:       " + core.Config.Firma.Pieczątka.REGON);
                colFirma.AddLine();

                colPracownik.AddLine(wypłata.Pracownik.ImięNazwisko.ToUpper());
                colPracownik.AddLine(wypłata.Pracownik.Adres.Linia1);
                colPracownik.AddLine(wypłata.Pracownik.Adres.Linia2);                
            }
		    
            static void Msg(object value) {
            }

</script>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<meta content="Microsoft Visual Studio 7.0" name="GENERATOR">
		<meta content="C#" name="CODE_LANGUAGE">
		<meta content="JavaScript" name="vs_defaultClientScript">
		<meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
	</HEAD>
	<body>
        <form id="form" method="post" runat="server">
		    <font face="Courier New" size="smaller">
				<ea:datacontext id="dc" runat="server" oncontextload="dc_OnContextLoad" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace" NextPagesHeader="-------- {0} --------"></ea:datacontext>
                <small></small><u></u><b></b>
				<ea:datarepeater id="repeater" runat="server" Height="294px" Width="875px" RowTypeName="Soneta.Place.WyplataEtat,Soneta.KadryPlace"
						onbeforerow="repeater_BeforeRow">
				<ea:Section id="Section1" runat="server" Width="130px" Pagination="True">
					<ea:PageBreak id="PageBreak" runat="server" Required="False" BreakFirstTimes="False"></ea:PageBreak>
                    <small>
					    <ea:TextGrid id="gridHeader" runat="server" RowTypeName="Soneta.Place.WyplataEtat, Soneta.KadryPlace" WithSections="False" ShowHeader="None" RowsInRow="4" Pagination="False" ShowLastLine="False" ShowFirstLine="False" OnBeforeRow="gridHeader_BeforeRow">
						    <Columns>
                                <ea:GridColumn runat="server" DataMember="Pracownik.ImięNazwisko" Width="45" Format="Pracownik: {0}"></ea:GridColumn>
                                <ea:GridColumn runat="server" Format="Za okres:  {0}" DataMember="ListaPlac.Okres"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="PracHistoria.PESEL" Format="PESEL:     {0}"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="PracHistoria.Etat.Zaszeregowanie.Wymiar" Format="Wymiar etatu: {0,8}"></ea:GridColumn>
                                
                                <ea:GridColumn runat="server" DataMember="ProcentPit" Format="Procent zal.:{0,12:n}%" Width="26"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="Workers.PITInfo.KosztyFIS" Format="Koszty uz.:{0,14:n}"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="Workers.PITInfo.Ulga" Format="Ulga podatkowa:{0,10:n}"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="Workers.PITInfo.ZalFIS" Format="Zal. podatku:{0,12:n}"></ea:GridColumn>
                                
                                <ea:GridColumn runat="server" DataMember="Workers.ZUSInfo.TytułUbezpieczenia" 
                                    Format="Tytuł ubezpiecz.:{0,11:n}" Width="29"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="PracHistoria.OddzialNFZ.Kod" Format="Oddział NFZ:{0,16:n}"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="Workers.PITInfo.ZdrowotneDoOdliczenia" Format="Zdrow.do odlicz.:{0,11:n}"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="Workers.PITInfo.ZdrowotnePracownika" Format="Zdrow. prac.:{0,15:n}"></ea:GridColumn>
                                <ea:GridColumn runat="server" DataMember="Numer"></ea:GridColumn>
                                <ea:GridColumn runat="server" ID="colRozliczenie" RowSpan="3"></ea:GridColumn>
						    </Columns>
					    </ea:TextGrid>
					    <ea:TextGrid id="gridElements" runat="server" onbeforerow="gridElements_BeforeRow" WithSections="False" Pagination="False">
						    <Columns>
							    <ea:GridColumn Width="3" BottomBorder="None" Align="Right" Caption="Lp." VAlign="Top" runat="server" ID="colLp" HideZero="True"></ea:GridColumn>
							    <ea:GridColumn BottomBorder="None" ID="colNazwa" NoWrap="True" VAlign="Top" runat="server" Width="41" Caption="Elementy wynagrodzenia"></ea:GridColumn>
							    <ea:GridColumn Width="8" Align="Right" Caption="Procent" HideZero="True" ID="colProcent" VAlign="Top" runat="server"></ea:GridColumn>
							    <ea:GridColumn Width="8" BottomBorder="None" Align="Right" Caption="godz:min" HideZero="True" ID="colCzas" VAlign="Top" runat="server"></ea:GridColumn>
							    <ea:GridColumn Width="8" BottomBorder="None" Align="Right" Caption="Dni" HideZero="True" ID="colDni" VAlign="Top" runat="server"></ea:GridColumn>
							    <ea:GridColumn Width="12" BottomBorder="None" Align="Right" Caption="Kwota" HideZero="True" Format="{0:n}" ID="colKwota" VAlign="Top" runat="server"></ea:GridColumn>
                                <ea:GridColumn ID="colPodstawy" runat="server" Width="16" Caption="Podstawy" Align="Center"></ea:GridColumn>
                                <ea:GridColumn ID="colUbezpieczony" runat="server" Caption="Ubezpieczony" Width="12" Align="Right" Format="{0:n}" HideZero="True"></ea:GridColumn>
                                <ea:GridColumn ID="colPłatnik" runat="server" Caption="Płatnik" Align="Right" Format="{0:n}" HideZero="True"></ea:GridColumn>
						    </Columns>
					    </ea:TextGrid>
                        <ea:TextGrid ID="gridKto" runat="server" OnBeforeRow="gridKto_BeforeRow" WithSections="False" Pagination="False" ShowFirstLine="False" ShowHeader="None" ShowLastLine="False">
                            <Columns>
                                <ea:GridColumn ID="colWho" runat="server" Width="63">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" RightBorder="None">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" RightBorder="None">
                                </ea:GridColumn>
                            </Columns>
                        </ea:TextGrid>
                        <ea:TextGrid ID="gridStopka" runat="server" OnBeforeRow="gridStopka_BeforeRow" WithSections="False" Pagination="False" ShowFirstLine="False" ShowHeader="None" ShowLastLine="False">
                            <Columns>
                                <ea:GridColumn runat="server" ID="colFirma" Width="63">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" RightBorder="None" Width="10">
                                </ea:GridColumn>
                                <ea:GridColumn runat="server" ID="colPracownik" RightBorder="None">
                                </ea:GridColumn>
                            </Columns>
                        </ea:TextGrid>
                    </small>
                    </ea:Section>
				</ea:datarepeater>
				<ea:PageBreak id="PageBreak1" runat="server" Required="true"></ea:PageBreak>
		    </font>
	    </form>
	</body>
</HTML>
