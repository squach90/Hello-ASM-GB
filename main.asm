INCLUDE "hardware.inc"

SECTION "Header", ROM0[$0100]
    nop
    jp main
    ds $150 - $104 ; alloc space for Nintendo Header

SECTION "tiles", ROM0
TileData:
    INCBIN "charGB.bin"
TileDataEnd:

SECTION "tilemap_data", ROM0
TileMapData:
    ; -----------------------------
    ; Partie fixe : Hello world
    ; -----------------------------
    db 8,37,44,44,47,0,55,47,50,44,36,0,41,46,0,1,19,13,70
    ds 32-20,0              ; compléter la ligne à 32 tiles

    ; -----------------------------
    ; Partie fixe : :)
    ; -----------------------------
    db 0,0,0,0,0,0,0,0,0,95,78
    ds 32-11,0              ; compléter la ligne à 32 tiles

    ; -----------------------------
    ; Partie vide pour séparer (15 lignes)
    ; -----------------------------
    ds 32*15,0

    ; -----------------------------
    ; Partie fixe : squach90
    ; -----------------------------
    db 0,0,0,0,0,0,51,49,53,33,35,40,94,85
    ds 32-14,0              ; compléter la ligne à 32 tiles

    ; -----------------------------
    ; Remplir le reste du tilemap pour atteindre 32*32 = 1024 octets
    ; -----------------------------
    ds 1024 - (32*32),0     ; ici on complète pour éviter toute zone non initialisée

TileMapDataEnd:


SECTION "main", ROM0
main:
    DI
    LD A, 0
    LDH [rLCDC], A      ; 0 to $FF40 to turn off screen

    ; === Copy tiles to VRAM ===
    LD HL, TileData
    LD DE, $8000        ; set to start of VRAM
    LD BC, TileDataEnd - TileData  ; nb of bytes to copy

.copy_tiles:
    LD A, [HL]          ; get first byte
    LD [DE], A          ; copy A to DE ($8000)
    INC HL              ; go to the next byte in TileData
    INC DE              ; go to the next addr in vram
    DEC BC              ; dec BC (nb of bytes) by 1

    LD A, B
    OR C
    JR NZ, .copy_tiles  ; Continue if BC != 0

    ; === Copy TileMap to VRAM ===
    LD HL, TileMapData
    LD DE, $9800        ; Tilemap start at $9800
    LD BC, TileMapDataEnd - TileMapData ; Tilemap Size

.copy_tilemap:
    LD A, [HL+]
    LD [DE], A
    INC DE
    DEC BC
    LD A, B
    OR C
    JR NZ, .copy_tilemap

    LD A, %11100100     ; Palette
    LDH [rBGP], A

    LD A, %10010001     ; LCD ON + BG ON + tile data at $8000
    LDH [rLCDC], A

.loop:
    HALT
    JP .loop

.wait_vblank:
    LDH A, [rLY]
    CP 144
    JR C, .wait_vblank

    JR .loop
