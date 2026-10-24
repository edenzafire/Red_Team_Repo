cat <<'EOF' > USAGE.md
# USAGE — phase 10 (report_builder.sh + deliverables)

## 1. Gerar a consolidação (mecânica)

```bash
cd 10_reporting
ROOT=$(cd .. && pwd) bash scripts/report_builder.sh
# saída: report/consolidated_findings.md (tabela + coverage ATT&CK + debrief inputs)
2. Curar (humano, onde humano pertence)
Instanciar templates/finding.tmpl.md por finding consolidado (F-01..F-n).
Preencher os placeholders do executive summary com risco de negócio.
Validar que nenhuma credencial viva migrou pra texto (o teste T2 ajuda).
3. Regras de ouro
Report é gerado, não escrito — o builder consolida; o analista analisa.
Nada inventado — linha sem artifact-fonte não entra (o builder garante).
Sem valores vivos — classes de credenciais, nunca segredos, no texto.
O debrief é obrigatório — o relatório sem o presente ao time azul é metade de um relatório.
Cleanup manifest assinado — apêndice D prova que nada ficou pra trás. 
