package br.com.laminarsoft.jazzitnotification;

import java.util.Date;

import org.simpleframework.xml.Attribute;
import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;

@Root
public class ArquivoVO {
	@Attribute public Integer codigo;
	@Attribute public String mensagem;
	
	@Attribute public Long id;
	@Attribute public Date dhInclusao;
	@Attribute public String nomeArquivo;
	@Attribute public String urlSite;
	@Attribute public String type;
	
	@Element public byte[] arqAnexo;
}
