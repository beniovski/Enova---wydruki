<%@ import Namespace="Soneta.Business" %>
<%@ import Namespace="Soneta.Tools" %>
<%@ import Namespace="Soneta.Types" %>
<%@ import Namespace="Soneta.Kadry" %>
<%@ import Namespace="Soneta.Place" %>
<%@ Register TagPrefix="cc1" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Page Language="c#" CodePage="1200" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<HTML>
	<HEAD>
		<title>Lista płac dodatków</title>
		<script runat="server">

    static bool hideOperator = false;

    public class Params : ContextBase {
    
        public Params(Context context) : base(context) {
        }

        bool tylkoDodatki = true;
        [Priority(10)]
        public bool TylkoDodatki {
            get { return tylkoDodatki; }
            set {
                tylkoDodatki = value;
                if (tylkoDodatki && definicja != null && definicja.RodzajZrodla != RodzajŹródłaWypłaty.Dodatek)
                    definicja = null;
                OnChanged(EventArgs.Empty);
            }
        }

        bool ukryjZablokowane = true;
        [Priority(20)]
        public bool UkryjZablokowane {
            get { return ukryjZablokowane; }
            set {
                ukryjZablokowane = value;
                if (!ukryjZablokowane && definicja != null && definicja.Blokada)
                    definicja = null;
                OnChanged(EventArgs.Empty);
            }
        }
        
		DefinicjaElementu definicja;
        [Priority(30)]
        [Required]
		public DefinicjaElementu Definicja {
			get { return definicja; }
			set { 
                definicja = value;
                OnChanged(EventArgs.Empty);
            }
		}

        public object GetListDefinicja() {
            Soneta.Business.View view = PlaceModule.GetInstance(Context).DefElementow.WgNazwy.CreateView();
            if (TylkoDodatki)
                view.Condition &= new FieldCondition.Equal("RodzajZrodla", RodzajŹródłaWypłaty.Dodatek);
            if (UkryjZablokowane)
                view.Condition &= new FieldCondition.NotEqual("Blokada", true);
            return view;
        }
    }
    
    Params pars;
    [Context]
    public Params Pars {
		set { pars = value; }
    }

    void Grid1_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
        int row = (int)args.Row;
        col1.EditValue = listyPłac[row * 6];
        if (listyPłac.Count > row * 6 + 1)
            col2.EditValue = listyPłac[row * 6 + 1];
        if (listyPłac.Count > row * 6 + 2)
            col3.EditValue = listyPłac[row * 6 + 2];
        if (listyPłac.Count > row * 6 + 3)
            col4.EditValue = listyPłac[row * 6 + 3];
        if (listyPłac.Count > row * 6 + 4)
            col5.EditValue = listyPłac[row * 6 + 4];
        if (listyPłac.Count > row * 6 + 5)
            col6.EditValue = listyPłac[row * 6 + 5];
    }	
		            
    void Grid2_BeforeRow(object sender, Soneta.Web.RowEventArgs args) {
		Wyplata wypłata = (Wyplata)args.Row;
		
		bool any = false;
		foreach (WypElement e in wypłata.Elementy)
			if (e.Definicja==pars.Definicja) {
				any = true;
				colOkres.AddLine(e.Okres);
				
				WypSkladnik skl = e.SkładnikGłówny;
				if (skl!=null) {
					colPodstawa1.AddLine(skl.Podstawa1);
					colPodstawa2.AddLine(skl.Podstawa2);
					colCzas.AddLine(skl.Czas);
					colDni.AddLine(skl.Dni);
					colWspolczynnik.AddLine(skl.Wspolczynnik);
					colIlosc.AddLine(skl.Ilosc);
				}
				else {
					colPodstawa1.AddLine(DoubleCy.Zero);
					colPodstawa2.AddLine(DoubleCy.Zero);
					colCzas.AddLine(Time.Zero);
					colDni.AddLine(0);
					colWspolczynnik.AddLine(0m);
					colIlosc.AddLine(0.0);
				}
				colWartość.AddLine(e.Wartosc);
			}
			
		args.VisibleRow &= any;
    }

    ArrayList listyPłac = new ArrayList();
				                
    void dc_ContextLoad(Object sender, EventArgs e) {
		Row[] rows = (Row[])dc[typeof(Row[])];
		ArrayList wypłaty = new ArrayList();
		ArrayList listy = new ArrayList();
		bool bufor = false;
		foreach (ListaPlac lista in rows) {
			bufor |= lista.Bufor;
			foreach (Wyplata w in lista.Wyplaty)
				wypłaty.Add(w);
            listyPłac.Add(lista.Numer.NumerPelny);
		}
				
        if (bufor)
            ReportHeader1["BUFOR"] = "Lista nie została zatwierdzona!|";
        else
            ReportHeader1["BUFOR"] = "";
            
        ReportHeader1["DEFINICJA"] = pars.Definicja.Nazwa;

        int count = listyPłac.Count / 6;
        if ((count * 6) != listyPłac.Count) count++;
        for (int i = 0; i < count; i++)
            listy.Add(i);
        Grid1.DataSource = listy;
        
        wypłaty.Sort();
        Grid2.DataSource = wypłaty;
            
        if (hideOperator)
			stOperator.SubtitleType = SubtitleType.Empty;         
			
		SetCaption(colPodstawa1, pars.Definicja.Algorytm.ElPodstawa1);
		SetCaption(colPodstawa2, pars.Definicja.Algorytm.ElPodstawa2);
		SetCaption(colCzas, pars.Definicja.Algorytm.ElCzas);
		SetCaption(colDni, pars.Definicja.Algorytm.ElDni);
		SetCaption(colWspolczynnik, pars.Definicja.Algorytm.ElWspolczynnik);
		SetCaption(colIlosc, pars.Definicja.Algorytm.ElIlosc);
    }
    
    static void SetCaption(GridColumn column, string caption) {
		if (caption=="")
			column.Visible = false;
		else
			column.Caption = caption.Substring(0, caption.Length-1);
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
		<form id="ProstaListaPłac" method="post" runat="server">
			<ea:datacontext id="dc" runat="server" RightMargin="-1" LeftMargin="-1" OnContextLoad="dc_ContextLoad"></ea:datacontext>
			<cc1:reportheader NagłówekOddziału="NagłówekOddziału" id="ReportHeader1" title="Lista płac dodatków|%BUFOR%</strong>Dodatek: <strong>%DEFINICJA%|</strong>Typ: <strong>{0}|</strong>Okres: <strong>{1}"
				runat="server" DataMember1="ListyPlacViewInfo+Params.Okres" DataMember0="ListyPlacViewInfo+Params.Typ"></cc1:reportheader>
			<ea:Grid id="Grid1" runat="server" onbeforerow="Grid1_BeforeRow">
				<Columns>
					<ea:GridColumn ID="col1" Caption="Listy płac~"></ea:GridColumn>
					<ea:GridColumn ID="col2" Caption="Listy płac~"></ea:GridColumn>
					<ea:GridColumn ID="col3" Caption="Listy płac~"></ea:GridColumn>
					<ea:GridColumn ID="col4" Caption="Listy płac~"></ea:GridColumn>
					<ea:GridColumn ID="col5" Caption="Listy płac~"></ea:GridColumn>
					<ea:GridColumn ID="col6" Caption="Listy płac~"></ea:GridColumn>
				</Columns>
			</ea:Grid>
            </br>
			<ea:Grid id="Grid2" runat="server" onbeforerow="Grid2_BeforeRow" RowTypeName="Soneta.Place.Wyplata, Soneta.KadryPlace">
				<Columns>
					<ea:GridColumn Width="4" Align="Right" DataMember="#" Caption="Lp" VAlign="Top"></ea:GridColumn>
					<ea:GridColumn DataMember="Pracownik" Total="Info" Caption="Pracownik"></ea:GridColumn>
					<ea:GridColumn Width="21" Caption="Okres" ID="colOkres"></ea:GridColumn>
					<ea:GridColumn Width="15" Align="Right" Caption="Podstawa 1" HideZero="True" ID="colPodstawa1"
						VAlign="Top"></ea:GridColumn>
					<ea:GridColumn Width="15" Align="Right" Caption="Podstawa 2" HideZero="True" ID="colPodstawa2"
						VAlign="Top"></ea:GridColumn>
					<ea:GridColumn Width="5" Align="Center" Caption="Czas" HideZero="True" ID="colCzas"></ea:GridColumn>
					<ea:GridColumn Width="5" Align="Center" Caption="Dni" HideZero="True" ID="colDni"></ea:GridColumn>
					<ea:GridColumn Width="10" Align="Right" Caption="Wsp&#243;łczynnik" HideZero="True" ID="colWspolczynnik"></ea:GridColumn>
					<ea:GridColumn Width="5" Align="Center" Caption="Ilość" HideZero="True" ID="colIlosc"></ea:GridColumn>
					<ea:GridColumn Width="15" Align="Right" Total="Sum" Caption="Wartość" Format="{0:n}" ID="colWartość"
						VAlign="Top"></ea:GridColumn>
				</Columns>
			</ea:Grid>
			<cc1:reportfooter id="ReportFooter1" runat="server">
				<SUBTITLES>
					<cc1:FooterSubtitle Caption="Sprawdzono pod względem merytorycznym" Width="50" SubtitleType="DataPodpis"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="Sprawdzono pod względem formalno prawnym" Width="50" SubtitleType="DataPodpis"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle id="stOperator" SubtitleType="Operator"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="data"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="główny księgowy"></cc1:FooterSubtitle>
					<cc1:FooterSubtitle Caption="kierownik jednostki"></cc1:FooterSubtitle>
				</SUBTITLES>
			</cc1:reportfooter>
		</form>
	</body>
</HTML>
