<%@ Register TagPrefix="ea" Namespace="Soneta.Web" Assembly="Soneta.Web" %>
<%@ Register TagPrefix="eb" Namespace="Soneta.Core.Web" Assembly="Soneta.Core.Web" %>
<%@ Page language="c#" AutoEventWireup="false" codePage="1250" %>
<%@ Import Namespace="Soneta.Types" %>
<%@ Import Namespace="Soneta.Business" %>
<%@ Import Namespace="Soneta.Core" %>
<%@ Import Namespace="Soneta.Place" %>
<%@ Import Namespace="System.Globalization" %>
<%@ import Namespace="System.Windows.Forms" %>
<script runat="server">

    void AddHeader() {
        Write("Class");
        Write("Opis");
        Write("NumerDokumentu");
        Write("DataOperacji");
        Write("DataDokumentu");
        Write("DataWplywu");


        Write("OpisAnalityczny:Class");
        Write("OpisAnalityczny:Wymiar");
        Write("OpisAnalityczny:Symbol");
        Write("OpisAnalityczny:Kwota");
        Write("OpisAnalityczny:Opis");

        WriteLn();
    }

    void AddLista(ListaPlac lista) {
        IDokumentKsiegowalny dk = (IDokumentKsiegowalny)lista;
        Write("PKEwidencja");
        Write(lista.Definicja.Symbol);
        Write(lista.Numer.NumerPelny);
        Write(dk.DataOperacji);
        Write(lista.Data);
        Write(dk.DataWpływu);        
        WriteLn();

        KsięgowanieListyWorker ksiw = new KsięgowanieListyWorker();
        ksiw.Lista = lista;

        KsięgowanieListyWorker.Raport raport = ksiw.Razem;
        AddKategoria(raport.Zasadnicze, "Zasadnicze");
        AddKategoria(raport.Umowy, "Umowy");
        AddKategoria(raport.Inne, "Inne");
        AddKategoria(raport.Zasiłki, "Zasiłki");
        AddKategoria(raport.DodatkiNetto, "DodatkiNetto");
        AddKategoria(raport.PotrąceniaNetto, "PotrąceniaNetto");
    }

    void AddKategoria(KsięgowanieListyWorker.RaportKategorii raport, string nazwa) {
        AddPozycja(raport.Wartość, "Wartość", nazwa);
        AddPozycja(raport.Razem, "Razem", nazwa);
        AddPozycja(raport.DoWyplaty, "DoWypłaty", nazwa);
        AddPozycja(raport.FP, "FunduszPracy", nazwa);
        AddPozycja(raport.FGŚP, "FGŚP", nazwa);
        AddPozycja(raport.FEP, "FEP", nazwa);
        AddPozycja(raport.Fundusze, "Fundusze", nazwa);
        AddPozycja(raport.Fis, "Fis", nazwa);
        AddPozycja(raport.Zdrowotne, "Zdrowotne", nazwa);
        AddPozycja(raport.SpoleczneFirma, "SpołeczneFirmy", nazwa);
        AddPozycja(raport.SpolecznePrac, "SpołecznePracownika", nazwa);
        AddPozycja(raport.Spoleczne, "Społeczne", nazwa);
        AddPozycja(raport.NarzutyFirma, "NarzutyFirmy", nazwa);
        AddPozycja(raport.NarzutyPrac, "NarzutyPracownika", nazwa);
        AddPozycja(raport.EmerFirma, "EmerytalneFirmy", nazwa);
        AddPozycja(raport.RentFirma, "RentoweFirmy", nazwa);
        AddPozycja(raport.ChorFirma, "ChoroboweFirmy", nazwa);
        AddPozycja(raport.WypadFirma, "WypadkoweFirmy", nazwa);
        AddPozycja(raport.ZdrowFirma, "ZdrowotneFirmy", nazwa);
        AddPozycja(raport.EmerPrac, "EmerytalnePracownika", nazwa);
        AddPozycja(raport.RentPrac, "RentowePracownika", nazwa);
        AddPozycja(raport.ChorPrac, "ChorobowePracownika", nazwa);
        AddPozycja(raport.WypadPrac, "WypadkowePracownika", nazwa);
        AddPozycja(raport.ZdrowPrac, "ZdrowotnePracownika", nazwa);
    }

    void AddPozycja(decimal kwota, string symbol, string wymiar) {
        if (kwota == 0)
            return;
        
        Write("");
        Write("");
        Write("");
        Write("");
        Write("");
        Write("");
        Write("ElementOpisuEwidencji");
        Write(wymiar);
        Write(symbol);
        Write(kwota);
        Write(wymiar + symbol);
        WriteLn();
    }
    
	void OnContextLoad(Object sender, EventArgs args) {
		Row[] rows = (Row[])dc[typeof(Row[])];

		Hashtable ht = new Hashtable();

        AddHeader();
        foreach (ListaPlac lista in rows)
            AddLista(lista);						
		
	}
	
	void WriteLn() {
		_Write("\r\n");
	}
	
	void Write(object obj) {
		_Write((obj==null ? "" : obj.ToString()) + ";");
	}
	
	void _Write(string s) {
		Response.Write(s);
	}
	
	//Pomocne w trakcie szukania błądów
	static object Msg(object value) {
        return value;
	}

</script>
<ea:datacontext id="dc" runat="server" oncontextload="OnContextLoad" TypeName="Soneta.Business.Row[],Soneta.Business" />
