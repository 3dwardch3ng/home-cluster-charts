{{- define "pi-hole.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pi-hole.labels" -}}
helm.sh/chart: {{ include "pi-hole.chart" . }}
{{ include "pi-hole.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "pi-hole.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "pi-hole.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pi-hole.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}