# cars_screenshot — Automação de Screenshots de Veículos para FiveM

> Resource FiveM para captura automatizada e em lote de screenshots de veículos, gerando imagens prontas para uso em lojas, HUDs, painéis web e sistemas de garage.

---

## O Problema que isso resolve

Em servidores FiveM com dezenas ou centenas de veículos customizados, gerar uma imagem de pré-visualização para cada um manualmente é inviável. Este resource automatiza todo o processo: spawna o veículo, posiciona a câmera, tira o print e salva o arquivo — sem intervenção humana.

---

## Como funciona

```
/purple:runScreenshot
```

1. Itera sobre a lista de veículos definida em `config.lua`
2. Spawna cada veículo nas coordenadas configuradas e o congela no lugar
3. Posiciona uma câmera scripted com offset configurável apontada para o veículo
4. Dispara um evento de servidor que solicita o screenshot via `screenshot-basic`
5. Decodifica o payload Base64 retornado e salva o arquivo `.png` diretamente no servidor
6. Avança para o próximo veículo automaticamente e repete o ciclo

---

## Arquitetura

```
cars_screenshot/
├── fxmanifest.lua   # Manifest do resource (FX Adamant / GTA5)
├── config.lua       # Coordenadas de spawn, offset de câmera e lista de veículos
├── main.lua         # Lógica client-side: spawn, câmera, fluxo de processamento
└── server.lua       # Lógica server-side: captura via screenshot-basic, decode Base64, gravação em disco
```

**Fluxo de dados:**

```
Client (main.lua)
  └─► Spawna veículo + posiciona câmera
  └─► TriggerServerEvent("cars_screenshot:saveImage")
        └─► Server (server.lua)
              └─► requestClientScreenshot (screenshot-basic)
              └─► Base64 decode (implementação própria, sem dependências externas)
              └─► SaveResourceFile → images/<model>.png
```

---

## Destaques técnicos

- **Decode Base64 próprio em Lua puro** — sem bibliotecas externas, portável para qualquer servidor
- **Timeout e fallback** — se o modelo não carregar ou o veículo não spawnar dentro do limite, o resource pula para o próximo sem travar o ciclo
- **Câmera scripted isolada** — `RenderScriptCams` com cleanup garantido, sem vazamento de câmeras entre iterações
- **Configuração centralizada** — coordenadas, offset de câmera e lista de veículos em um único arquivo
- **Zero dependências além de `screenshot-basic`** — resource leve, sem frameworks

---

## Configuração

```lua
-- config.lua
_G.CONFIG = {
  FOLDER       = 'images',                          -- pasta de destino dos .png
  SPAWN_COORDS = vector4(-74.65, -818.12, 326.18, 116.23), -- posição + heading do veículo
  CAM_OFFSET   = vector3(5.0, -5.0, 1.5),           -- offset XYZ da câmera em relação ao spawn
  VEHICLE_LIST = {
    'adder',
    'zentorno',
    -- adicione quantos modelos quiser
  }
}
```

---

## Requisitos

| Dependência | Versão |
|---|---|
| FiveM (FX Adamant) | qualquer |
| [screenshot-basic](https://github.com/citizenfx/screenshot-basic) | latest |

---

## Casos de uso

- Geração de thumbnails para **lojas de veículos** (esx_vehicleshop, qb-vehicleshop, etc.)
- Pré-visualização em **painéis web de administração**
- Catálogos de garage para **UIs customizadas**
- Documentação interna de **packs de veículos**

---

## Autor

**Kauan Araujo** — [GitHub @KauanAraujoDev](https://github.com/KauanAraujoDev)
