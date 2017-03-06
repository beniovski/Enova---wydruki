<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Core" %>
<%@ Register TagPrefix="n0" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title></title>
		<script runat="server">

            static bool procentInfo = false;
            static bool skladnikiInfo = false;
            static bool procentPit = false;
            //Włącza drukowanie podsumowania funduszy pożyczkowych. UWAGA! Informacja wg stanu
            //aktualnego a nie na dzień wypłaty.
            static bool funduszePożyczkowe = false;
            static bool daneFirmy = true;
            static bool fundusze = false;

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

                bool forceBreak = false;
                [Caption("Na osobnych stronach")]
                [Priority(2)]
                public bool ForceBreak {
                    get { return forceBreak; }
                    set {
                        forceBreak = value;
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
                if (!procentPit) {
                    colPitInfo.Format = "";
                    colPitProcent.DataMember = "";
                }

                PageBreak.Required = Pars.ForceBreak;
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

                colProcent.Visible = procentInfo;

                if (daneFirmy) {
                    GridFirma.DataSource = new object[] { dc.Session };
                    CoreModule core = CoreModule.GetInstance(dc);
                    string ss = core.Config.Firma.Pieczątka.NUSP;
                    if (ss == "") {
                        colNuspTitle.Format = "REGON:";
                        ss = core.Config.Firma.Pieczątka.REGON;
                    }
                    colNUSP.Format = ss;
                }
                else
                    GridFirma.Visible = daneFirmy;

                if (!fundusze) {
                    gridHeader.RowsInRow -= 3;

                    optEmptyBegin.Visible = false;
                    optPodstawa.Visible = false;
                    optSkladka.Visible = false;

                    optFP.Visible = false;
                    optFPPodstawa.Visible = false;
                    optFPSkladka.Visible = false;

                    optFGSP.Visible = false;
                    optFGSPPodstawa.Visible = false;
                    optFGSPSkladka.Visible = false;

                    optFEP.Visible = false;
                    optFEPPodstawa.Visible = false;
                    optFEPSkladka.Visible = false;
                    
                    optEmptyEnd.Visible = false;
                }
                
                labelCopyright.EditValue = dc.Copyright;
            }

            private void repeater_BeforeRow(object sender, System.EventArgs e) {
                Wyplata wypłata = (Wyplata)repeater.CurrentRow;
                gridHeader.DataSource = new object[] { new ContextObject(wypłata, dc.Context) };
                GridOperator.DataSource = gridHeader.DataSource;

                ArrayList fundusze = new ArrayList();
                foreach (FundPozyczkowy f in wypłata.Pracownik.FunduszePozyczkowe)
                    fundusze.Add(f);

                if (fundusze.Count == 0 || !funduszePożyczkowe || !(wypłata is WyplataEtat)) {
                    gridFundusze.Visible = false;
                    gridFundusze.DataSource = new object[] { };
                }
                else {
                    gridFundusze.Visible = true;
                    gridFundusze.DataSource = new ListWithView(fundusze, wypłata.Pracownik.Module.FundPozyczkowe.PrimaryKey);
                }
            }

            private void gridHeader_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
                Wyplata wypłata = (Wyplata)repeater.CurrentRow;

                WyplataEtat we = wypłata as WyplataEtat;
                Wyplata.ZUSInfoWorker zusinfo = new Wyplata.ZUSInfoWorker();
                zusinfo.Wypłata = wypłata;
                if (we != null)
                    colPracInfo.EditValue = string.Format("PESEL: {0} Wymiar etatu: {1} Tytuł ubezpieczenia: {2}",
                        wypłata.PracHistoria.PESEL,
                        wypłata.PracHistoria.Etat.Zaszeregowanie.Wymiar,
                        zusinfo.TytułUbezpieczenia/*wypłata.PracHistoria.Etat.Ubezpieczenia.Tyub*/);
                else {
                    Umowa umowa = wypłata is WyplataUmowa ? ((WyplataUmowa)wypłata).Umowa : null;
                    if (umowa != null)
                        colPracInfo.EditValue = string.Format("PESEL: {0} Tytuł ubezpieczenia: {1}",
                            wypłata.PracHistoria.PESEL,
                            zusinfo.TytułUbezpieczenia/*umowa.Ubezpieczenia.Tyub*/);
                    else
                        colPracInfo.EditValue = string.Format("PESEL: {0}",
                            wypłata.PracHistoria.PESEL);
                }

                colGotowka.EditValue = wypłata.Gotówka;
                colROR.EditValue = wypłata.Inne;
            }

            void AddWartosc(decimal v) {
                if (v >= 0) {
                    colDodatek.AddLine(v);
                    colPotracenie.AddLine(0m);
                }
                else {
                    colDodatek.AddLine(0m);
                    colPotracenie.AddLine(-v);
                }
            }

	        static readonly string prefix = "&nbsp;&nbsp;&nbsp;&nbsp;";
		    
            private void gridElements_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
                WypElement element = (WypElement)args.Row;

                if (!skladnikiInfo) {
                    if (element.Wartosc == 0)
                        args.VisibleRow = false;
                    else {
                        colNazwa.AddLine(element.Nazwa);
                        WypSkladnikGłówny skg = element.SkładnikGłówny;
                        colProcent.AddLine(skg == null ? Percent.Zero : skg.Procent);
                        colCzas.AddLine(element.Czas);
                        colDni.AddLine(element.Dni);
                        AddWartosc(element.Wartosc);
                    }
                }
                else
                    foreach (WypSkladnik sk in element.Skladniki) {
                        WypSkladnikGłówny skg = sk as WypSkladnikGłówny;
                        if (skg != null) {
                            colNazwa.AddLine(element.Nazwa);
                            colProcent.AddLine(skg.Procent);
                            colCzas.AddLine(skg.Czas);
                            colDni.AddLine(skg.Dni);
                            AddWartosc(skg.Wartosc);
                        }
                        else {
                            WypSkladnikPomniejszenie skp = sk as WypSkladnikPomniejszenie;
                            if (skp != null) {
                                colNazwa.AddLine(prefix + skp.Nieobecnosc.Definicja.Nazwa + " (" + skp.Okres + ")");
                                colProcent.AddLine(skp.Procent);
                                colCzas.AddLine(skp.Czas);
                                colDni.AddLine(skp.Dni);
                                colDodatek.AddLine(skp.Wartosc);
                                colPotracenie.AddLine(0m);
                            }
                            else {
                                colNazwa.AddLine(prefix + CaptionAttribute.EnumToString(sk.Rodzaj));
                                colProcent.AddLine(sk.Procent);
                                colCzas.AddLine(sk.Czas);
                                colDni.AddLine(sk.Dni);
                                colDodatek.AddLine(sk.Wartosc);
                                colPotracenie.AddLine(0m);
                            }
                        }
                    }
            }

            private void GridOperator_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
                colToday.EditValue = Date.Today;
                colOperator.EditValue = dc.Session.Login.Operator.FullName;
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
		<font face="Courier New" size="smaller">
			<form id="form" method="post" runat="server">
				<ea:datacontext id="dc" runat="server" oncontextload="dc_OnContextLoad" TypeName="Soneta.Place.ListaPlac, Soneta.KadryPlace"></ea:datacontext>
                <small></small><u></u><b></b>
				<ea:datarepeater id="repeater" runat="server" Height="294px" Width="875px" RowTypeName="Soneta.Place.WyplataEtat,Soneta.KadryPlace"
						onbeforerow="repeater_BeforeRow">
				<ea:Section id="Section1" runat="server" Width="130px" Pagination="True">
					<ea:PageBreak id="PageBreak" runat="server" Required="False" BreakFirstTimes="False"></ea:PageBreak>
					<small><ea:TextGrid id="GridFirma" runat="server" RowTypeName="Soneta.Business.Session,Soneta.Business"
						WithSections="False" ShowHeader="None" RowsInRow="3" Pagination="False">
						<Columns>
							<ea:GridColumn RightBorder="None" Format="Nazwa firmy: " ID="colFirmaTitle" runat="server" Width="13"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="NIP:" ID="colNipTitle" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="NUSP:" ID="colNuspTitle" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="None" DataMember="Core.Config.Firma.Pieczątka.Nazwa"
								ID="colNazwaFirmy" runat="server" Width="69"></ea:GridColumn>
							<ea:GridColumn DataMember="Core.Config.Firma.Pieczątka.NIP"
								ID="colNIP" runat="server"></ea:GridColumn>
							<ea:GridColumn ID="colNUSP" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="|......................................|(pieczęć firmy)"
								ID="colStempel" RowSpan="3" VAlign="Bottom" runat="server"></ea:GridColumn>
						</Columns>
					</ea:TextGrid>
					<ea:TextGrid id="gridHeader" runat="server" onbeforerow="gridHeader_BeforeRow" RowTypeName="Soneta.Place.WyplataEtat, Soneta.KadryPlace"
						WithSections="False" ShowHeader="None" RowsInRow="10" Pagination="False">
						<Columns>
							<ea:GridColumn RightBorder="None" Format="Pracownik:" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Za okres:" runat="server"></ea:GridColumn>
							<ea:GridColumn ColSpan="5" BottomBorder="Single" ID="colPracInfo" runat="server"></ea:GridColumn>
							<ea:GridColumn runat="server"></ea:GridColumn>
							<ea:GridColumn Format="Podstawa:" runat="server"></ea:GridColumn>
							<ea:GridColumn Format="Ubezpieczony:" runat="server"></ea:GridColumn>
							<ea:GridColumn Format="Płatnik:" runat="server"></ea:GridColumn>
                            <ea:GridColumn ID="optEmptyBegin" runat="server"></ea:GridColumn>
                            <ea:GridColumn ID="optPodstawa" runat="server" Format="Podstawa:"></ea:GridColumn>
                            <ea:GridColumn ID="optSkladka" runat="server" Format="Składka:"></ea:GridColumn>
							<ea:GridColumn ColSpan="4" DataMember="Pracownik" runat="server"></ea:GridColumn>
							<ea:GridColumn ColSpan="4" DataMember="ListaPlac.Okres" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Emerytalne" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Emerytalna.Podstawa" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Emerytalna.Prac" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Emerytalna.Firma" Format="{0:n}" runat="server"></ea:GridColumn>
                            <ea:GridColumn ID="optFP" runat="server" Align="Center" Format="FP"></ea:GridColumn>
                            <ea:GridColumn ID="optFPPodstawa" runat="server" Align="Right" DataMember="Workers.WyplataSkładki.Razem.FP.Podstawa" Format="{0:n}"></ea:GridColumn>
                            <ea:GridColumn ID="optFPSkladka" runat="server" Align="Right" DataMember="Workers.WyplataSkładki.Razem.FP.Firma" Format="{0:n}"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Rentowe" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Rentowa.Podstawa" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Rentowa.Prac" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Rentowa.Firma" Format="{0:n}" runat="server"></ea:GridColumn>
                            <ea:GridColumn ID="optFGSP" runat="server" Align="Center" Format="FGŚP"></ea:GridColumn>
                            <ea:GridColumn ID="optFGSPPodstawa" runat="server" Align="Right" DataMember="Workers.WyplataSkładki.Razem.FGSP.Podstawa" Format="{0:n}"></ea:GridColumn>
                            <ea:GridColumn ID="optFGSPSkladka" runat="server" Align="Right" DataMember="Workers.WyplataSkładki.Razem.FGSP.Firma" Format="{0:n}"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Chorobowe" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Chorobowa.Podstawa" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Chorobowa.Prac" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Chorobowa.Firma" Format="{0:n}" runat="server"></ea:GridColumn>
                            <ea:GridColumn ID="optFEP" runat="server" Align="Center" Format="FEP"></ea:GridColumn>
                            <ea:GridColumn ID="optFEPPodstawa" runat="server" Align="Right" DataMember="Workers.WyplataSkładki.Razem.FEP.Podstawa" Format="{0:n}"></ea:GridColumn>
                            <ea:GridColumn ID="optFEPSkladka" runat="server" Align="Right" DataMember="Workers.WyplataSkładki.Razem.FEP.Firma" Format="{0:n}"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Wypadkowe" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Wypadkowa.Podstawa" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Wypadkowa.Prac" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Wypadkowa.Firma" Format="{0:n}" runat="server"></ea:GridColumn>
                            <ea:GridColumn ID="optEmptyEnd" runat="server" ColSpan="5" RowSpan="3"></ea:GridColumn>
							<ea:GridColumn ColSpan="2" DataMember="Numer" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Oddział NFZ:" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" BottomBorder="Single" Format="Procent PIT:" ID="colPitInfo" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Razem" runat="server"></ea:GridColumn>
							<ea:GridColumn runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.KosztyZUS" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.FirmaZUS" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn DataMember="PracHistoria.OddzialNFZ.Kod" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="Single" DataMember="Workers.PITInfo.ProcentPit" ID="colPitProcent" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Zdrowotne" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Zdrowotna.Podstawa" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Zdrowotna.Prac" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.WyplataSkładki.Razem.Zdrowotna.Firma" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Koszty uz.:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Ulga podatkowa:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Zdrow.do odlicz:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Zdrow. prac.:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Zal. podatku:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="Got&#243;wka:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn RightBorder="None" Format="ROR:" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.KosztyFIS" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.Ulga" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZdrowotneDoOdliczenia" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZdrowotnePracownika" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" DataMember="Workers.PITInfo.ZalFIS" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colGotowka" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Right" ID="colROR" runat="server"></ea:GridColumn>
						</Columns>
					</ea:TextGrid>
					<ea:TextGrid id="gridElements" runat="server" onbeforerow="gridElements_BeforeRow" WithSections="False"
						DataMember="ElementyWgKolejności" Pagination="False">
						<Columns>
							<ea:GridColumn Width="4" BottomBorder="None" Align="Right" DataMember="#" Caption="L.p." VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn BottomBorder="None" Total="Info" ID="colNazwa" NoWrap="True" VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="10" BottomBorder="None" Align="Right" Caption="Procent" HideZero="True" ID="colProcent"
								VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="10" BottomBorder="None" Align="Right" Caption="godz:min" HideZero="True"
								ID="colCzas" VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="10" BottomBorder="None" Align="Right" Caption="Dni" HideZero="True" ID="colDni"
								VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="15" BottomBorder="None" Align="Right" Total="Sum" Caption="Dodatek" HideZero="True"
								Format="{0:n}" ID="colDodatek" VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="15" BottomBorder="None" Align="Right" Total="Sum" Caption="Potrącenie" HideZero="True"
								Format="{0:n}" ID="colPotracenie" VAlign="Top" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="25" BottomBorder="None" Caption="Data i podpis" runat="server"></ea:GridColumn>
						</Columns>
					</ea:TextGrid>
					<ea:TextGrid id="gridFundusze" runat="server" WithSections="False" Pagination="False">
						<Columns>
							<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption="L.p." runat="server"></ea:GridColumn>
							<ea:GridColumn Width="30" DataMember="Definicja.Nazwa" Caption="Fundusz" NoWrap="True" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="15" Align="Right" DataMember="Workers.FundPożyczkowy.Wkład" Caption="Wkład"
								HideZero="True" Format="{0:n}" runat="server"></ea:GridColumn>
							<ea:GridColumn Width="15" Align="Right" DataMember="Workers.FundPożyczkowy.DoSpłaty" Caption="Do spłaty"
								HideZero="True" Format="{0:n}" runat="server"></ea:GridColumn>
						</Columns>
					</ea:TextGrid>
					<ea:TextGrid id="GridOperator" runat="server" onbeforerow="GridOperator_BeforeRow" WithSections="False"
						ShowHeader="None" Pagination="False">
						<Columns>
							<ea:GridColumn Align="Center" Format="Data sporządzenia: {0}" ID="colToday" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="Sporządził: {0}" ID="colOperator" runat="server"></ea:GridColumn>
							<ea:GridColumn Align="Center" Format="|............|podpis" runat="server"></ea:GridColumn>
						</Columns>
					</ea:TextGrid>
                    <ea:DataLabel ID="labelCopyright" runat="server" Align="Right" Bold="False" WidthChars="130"></ea:DataLabel><br></small>
                    </ea:Section>
				</ea:datarepeater>
				<ea:PageBreak id="PageBreak1" runat="server" Required="true"></ea:PageBreak>
			</form>
		</font>
	</body>
</HTML>

