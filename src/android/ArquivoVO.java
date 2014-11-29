package br.com.laminarsoft.jazzitnotification;

import org.simpleframework.xml.Attribute;
import org.simpleframework.xml.Element;
import org.simpleframework.xml.Root;

@Root
public class ArquivoVO {
	@Attribute public Integer codigo;
	@Attribute public String mensagem;
	
	@Attribute public Long id;
	@Attribute public String nomeArquivo;
	@Attribute public Long dhInclusao;
	@Attribute public String urlSite;
	@Attribute public String type;
	
	@Element public String arqAnexo;
}
