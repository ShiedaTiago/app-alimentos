# Modelo de Dados (Cloud Firestore)

Nomes de campos em inglês, camelCase. Datas como `Timestamp`. Enums salvos como string (`'fridge'`, `'meat'`...).

```
users/{uid}
households/{householdId}
  ├─ storages/{storageId}
  ├─ items/{itemId}
  ├─ tags/{tagId}          [F] TCC
  └─ readings/{readingId}  [F] TCC
inviteCodes/{code}
```

## users/{uid}
| Campo | Tipo | Obs |
|---|---|---|
| name | string | |
| email | string | |
| photoUrl | string? | vem do Google |
| householdId | string? | null até criar/entrar numa casa |
| createdAt | timestamp | |

## households/{householdId}
| Campo | Tipo | Obs |
|---|---|---|
| name | string | ex.: "Casa do Tiago" |
| ownerId | string | uid de quem criou |
| memberIds | array<string> | uids dos membros — base das regras de segurança |
| inviteCode | string | 6 chars, ver RN03 |
| createdAt | timestamp | |

## inviteCodes/{code}
| Campo | Tipo | Obs |
|---|---|---|
| householdId | string | permite achar a casa pelo código antes de ser membro |

## households/{id}/storages/{storageId}
| Campo | Tipo | Obs |
|---|---|---|
| name | string | "Geladeira" |
| type | string | `fridge` \| `freezer` \| `pantry` |
| minTemp / maxTemp | number? | [F] faixa segura em °C, para alertas do sensor |
| deviceId | string? | [F] ESP32 ligado a este local |

## households/{id}/items/{itemId}
| Campo | Tipo | Obs |
|---|---|---|
| name | string | |
| category | string | enum FoodCategory |
| quantity | number | > 0 |
| unit | string | enum FoodUnit |
| expiresAt | timestamp | só a data importa (00:00 local) |
| storageId | string | |
| notes | string? | |
| barcode | string? | EAN, se escaneado |
| status | string | `active` \| `consumed` \| `discarded` |
| source | string | `manual` \| `barcode` \| `rfid` |
| tagId | string? | [F] etiqueta RFID vinculada |
| lastSeenAt | timestamp? | [F] última vez que a antena leu |
| addedBy | string | uid |
| createdAt / updatedAt | timestamp | |
| closedAt | timestamp? | quando virou consumed/discarded |

Consulta principal: `items where status == 'active' orderBy expiresAt` → pode exigir **índice composto** (o Firestore mostra o link para criar no erro do console).

## households/{id}/tags/{tagId}  [F]
`tagId` = EPC da etiqueta. Campos: `status` (`pending` \| `linked`), `itemId?`, `storageId`, `firstSeenAt`, `lastSeenAt`. Uma tag `pending` é o que o app mostra como "nova etiqueta detectada".

## households/{id}/readings/{readingId}  [F]
`storageId`, `temperature` (°C), `humidity` (%), `readAt`.

## assets/recipes.json (local, não fica no Firestore)
```json
[
  {
    "id": "omelete-legumes",
    "title": "Omelete de legumes",
    "minutes": 15,
    "ingredients": [
      { "name": "ovo", "keywords": ["ovo", "ovos"], "optional": false },
      { "name": "tomate", "keywords": ["tomate"], "optional": true }
    ],
    "steps": ["Bata os ovos...", "..."]
  }
]
```
Casamento ingrediente ↔ alimento: nome do alimento normalizado (minúsculas, sem acento) contém alguma `keyword`. Meta: ~20 receitas simples e variadas.

## Regras de segurança (firestore.rules) — base
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }
    function isMember(hid) {
      return signedIn() &&
        request.auth.uid in get(/databases/$(database)/documents/households/$(hid)).data.memberIds;
    }

    match /users/{uid} {
      allow read, write: if signedIn() && request.auth.uid == uid;
      // membros da mesma casa podem ler o nome uns dos outros (lista de membros)
      allow read: if signedIn() && resource.data.householdId != null && isMember(resource.data.householdId);
    }

    match /inviteCodes/{code} {
      allow get: if signedIn();          // só leitura direta pelo código, sem listar
      allow create: if signedIn();
    }

    match /households/{hid} {
      allow create: if signedIn() && request.resource.data.memberIds == [request.auth.uid];
      allow read, update, delete: if isMember(hid);
      // entrar na casa: só pode adicionar a si mesmo em memberIds
      allow update: if signedIn()
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['memberIds'])
        && request.resource.data.memberIds.hasAll(resource.data.memberIds)
        && request.resource.data.memberIds.size() == resource.data.memberIds.size() + 1
        && request.auth.uid in request.resource.data.memberIds;

      match /{sub=**} {
        allow read, write: if isMember(hid);
      }
    }
  }
}
```
Testar no **Rules Playground** do console antes da entrega: um usuário da casa A não pode ler `households/B/items`.
