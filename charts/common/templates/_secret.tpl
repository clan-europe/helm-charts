{{- define "common.secret" -}}
{{- $s := .Values.secrets | default dict -}}
{{- if not $s.existingSecret -}}
{{- if include "common.hasSecrets" . -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
type: Opaque
stringData:
  {{- range $k, $v := omit $s "existingSecret" }}
  {{- with $v }}
  {{ $k }}: {{ . | quote }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
