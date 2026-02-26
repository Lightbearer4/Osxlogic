--[[
    ╔══════════════════════════════════════════════════════════╗
    ║           OSXMA: THE FINAL OVERRIDE v1.0.0              ║
    ║         Advanced Security Logic & Automation            ║
    ║                  © Osxma Dev Organization               ║
    ╚══════════════════════════════════════════════════════════╝
    
    Módulos:
        [1] Sistema de Autenticación por Roles
        [2] Protocolos de Infiltración Simulada
        [3] Motor de Logs y Trazabilidad
        [4] Manejador de Errores con pcall
    
    Autores:
        Co-Líder   : Osxma Core
        Ingeniero  : Israel
        Hacker     : Michael
]]

-- ============================================================
--  CONSTANTES GLOBALES
-- ============================================================

local VERSION   = "1.0.0"
local SYS_NAME  = "OSXMA:OVERRIDE"
local MAX_RETRY = 3

-- Niveles de log
local LOG_LEVEL = {
    INFO  = "[INFO]",
    WARN  = "[WARN]",
    ERROR = "[ERROR]",
    SYS   = "[SYS] ",
    HACK  = "[HACK]",
}

-- ============================================================
--  MÓDULO 1 · MOTOR DE LOGS
-- ============================================================

local Logger = {}
Logger.__index = Logger

--- Crea una nueva instancia del logger.
--- @param prefix string  Prefijo identificador del módulo
--- @return table
function Logger.new(prefix)
    return setmetatable({ prefix = prefix or "CORE", history = {} }, Logger)
end

--- Emite un mensaje con timestamp simulado y nivel.
--- @param level  string  Nivel del log (INFO, WARN, ERROR, etc.)
--- @param msg    string  Mensaje a registrar
function Logger:emit(level, msg)
    local entry = string.format(
        "[%s][%s]%s %s",
        SYS_NAME,
        self.prefix,
        level,
        msg
    )
    table.insert(self.history, entry)
    print(entry)
end

--- Retorna todo el historial de logs como string.
--- @return string
function Logger:dump()
    return table.concat(self.history, "\n")
end


-- ============================================================
--  MÓDULO 2 · SISTEMA DE AUTENTICACIÓN POR ROLES
-- ============================================================

local AuthSystem = {}
AuthSystem.__index = AuthSystem

-- Definición de roles y permisos
local ROLE_DEFINITIONS = {
    ["CO_LEADER"] = {
        label       = "Co-Líder",
        clearance   = 10,
        permissions = { "READ", "WRITE", "EXECUTE", "OVERRIDE", "ADMIN" },
    },
    ["ENGINEER"] = {
        label       = "Ingeniero",
        clearance   = 6,
        permissions = { "READ", "WRITE", "EXECUTE", "DEPLOY" },
        assignee    = "Israel",
    },
    ["HACKER"] = {
        label       = "Hacker Ético",
        clearance   = 8,
        permissions = { "READ", "EXECUTE", "PROBE", "BYPASS_SIM" },
        assignee    = "Michael",
    },
}

-- Registro de usuarios activos del sistema
local USER_REGISTRY = {
    { id = "USR-001", username = "osxma_root",  role = "CO_LEADER", token = "TKN-ALPHA-7X" },
    { id = "USR-002", username = "israel_eng",  role = "ENGINEER",  token = "TKN-BRAVO-3K" },
    { id = "USR-003", username = "michael_sec", role = "HACKER",    token = "TKN-DELTA-9M" },
}

--- Crea una nueva instancia del sistema de autenticación.
--- @return table
function AuthSystem.new()
    local self  = setmetatable({}, AuthSystem)
    self.log    = Logger.new("AUTH")
    self.active = {}   -- sesiones activas { token -> user }
    return self
end

--- Busca un usuario en el registro por token.
--- @param token string
--- @return table|nil
function AuthSystem:_findByToken(token)
    for _, user in ipairs(USER_REGISTRY) do
        if user.token == token then return user end
    end
    return nil
end

--- Verifica si un rol posee un permiso específico.
--- @param roleKey   string
--- @param perm      string
--- @return boolean
function AuthSystem:_hasPermission(roleKey, perm)
    local role = ROLE_DEFINITIONS[roleKey]
    if not role then return false end
    for _, p in ipairs(role.permissions) do
        if p == perm then return true end
    end
    return false
end

--- Autentica a un usuario por token y lo registra en sesiones activas.
--- @param token string
--- @return boolean, string  éxito, mensaje
function AuthSystem:authenticate(token)
    self.log:emit(LOG_LEVEL.INFO, string.format("Intento de autenticación · token=%s", token))

    local user = self:_findByToken(token)
    if not user then
        self.log:emit(LOG_LEVEL.ERROR, "Token inválido. Acceso denegado.")
        return false, "TOKEN_INVALID"
    end

    local roleDef = ROLE_DEFINITIONS[user.role]
    self.active[token] = {
        user      = user,
        role      = roleDef,
        loginTime = os.time(),
    }

    self.log:emit(LOG_LEVEL.INFO, string.format(
        "Sesión iniciada · usuario=%s · rol=%s · clearance=%d",
        user.username, roleDef.label, roleDef.clearance
    ))
    return true, "AUTH_OK"
end

--- Cierra la sesión de un token activo.
--- @param token string
function AuthSystem:logout(token)
    if self.active[token] then
        local u = self.active[token].user
        self.log:emit(LOG_LEVEL.INFO, string.format("Sesión cerrada · usuario=%s", u.username))
        self.active[token] = nil
    end
end

--- Verifica si un token activo tiene un permiso requerido.
--- @param token string
--- @param perm  string
--- @return boolean
function AuthSystem:authorize(token, perm)
    local session = self.active[token]
    if not session then
        self.log:emit(LOG_LEVEL.WARN, "Autorización fallida: sesión no activa.")
        return false
    end
    local ok = self:_hasPermission(session.user.role, perm)
    local status = ok and "GRANTED" or "DENIED"
    self.log:emit(LOG_LEVEL.INFO, string.format(
        "Permiso [%s] → %s · usuario=%s", perm, status, session.user.username
    ))
    return ok
end


-- ============================================================
--  MÓDULO 3 · PROTOCOLOS DE INFILTRACIÓN SIMULADA
-- ============================================================

local InfiltrationEngine = {}
InfiltrationEngine.__index = InfiltrationEngine

-- Capas de seguridad a atravesar (simuladas)
local SECURITY_LAYERS = {
    { id = 1, name = "Firewall Perimetral",    difficulty = 2, bypassMethod = "PACKET_SPOOF_SIM"  },
    { id = 2, name = "IDS/IPS Monitor",        difficulty = 5, bypassMethod = "SIGNATURE_EVASION" },
    { id = 3, name = "Auth Gateway",           difficulty = 7, bypassMethod = "TOKEN_REPLAY_SIM"  },
    { id = 4, name = "Kernel Security Module", difficulty = 9, bypassMethod = "PRIVILEGE_ESC_SIM" },
}

--- Crea una nueva instancia del motor de infiltración.
--- @param auth  table  Instancia de AuthSystem
--- @return table
function InfiltrationEngine.new(auth)
    local self  = setmetatable({}, InfiltrationEngine)
    self.auth   = auth
    self.log    = Logger.new("INFIL")
    self.report = {}   -- reporte final de la sesión
    return self
end

--- Simula el intento de bypass de una capa de seguridad.
--- La dificultad se resuelve contra el clearance del usuario.
--- @param layer   table    Capa de seguridad
--- @param session table    Sesión activa del usuario
--- @return boolean, string
function InfiltrationEngine:_bypassLayer(layer, session)
    local clearance = session.role.clearance
    self.log:emit(LOG_LEVEL.HACK, string.format(
        "Atacando capa [%d] '%s' · método=%s · dificultad=%d · clearance=%d",
        layer.id, layer.name, layer.bypassMethod, layer.difficulty, clearance
    ))

    -- Lógica de resolución: clearance debe superar la dificultad
    if clearance >= layer.difficulty then
        self.log:emit(LOG_LEVEL.HACK, string.format(
            "✓ Capa [%d] comprometida · %s", layer.id, layer.name
        ))
        return true, "LAYER_BYPASSED"
    else
        self.log:emit(LOG_LEVEL.WARN, string.format(
            "✗ Capa [%d] resistió el ataque · clearance insuficiente", layer.id
        ))
        return false, "INSUFFICIENT_CLEARANCE"
    end
end

--- Ejecuta el protocolo completo de infiltración para un token dado.
--- Requiere permiso BYPASS_SIM o OVERRIDE.
--- @param token string
--- @return table  Reporte de la operación
function InfiltrationEngine:runProtocol(token)
    self.log:emit(LOG_LEVEL.SYS, "══ INICIANDO PROTOCOLO DE INFILTRACIÓN ══")

    -- Verificar que la sesión existe y tiene permiso
    local session = self.auth.active[token]
    if not session then
        self.log:emit(LOG_LEVEL.ERROR, "Protocolo abortado: sin sesión activa.")
        return { success = false, reason = "NO_SESSION" }
    end

    local hasAccess = self.auth:authorize(token, "BYPASS_SIM")
                   or self.auth:authorize(token, "OVERRIDE")

    if not hasAccess then
        self.log:emit(LOG_LEVEL.ERROR, "Acceso denegado al protocolo de infiltración.")
        return { success = false, reason = "ACCESS_DENIED" }
    end

    -- Iterar capas
    local results       = {}
    local layersFailed  = 0

    for _, layer in ipairs(SECURITY_LAYERS) do
        local ok, status = self:_bypassLayer(layer, session)
        table.insert(results, {
            layerId = layer.id,
            name    = layer.name,
            status  = status,
            passed  = ok,
        })
        if not ok then layersFailed = layersFailed + 1 end
    end

    local overallSuccess = (layersFailed == 0)
    self.log:emit(LOG_LEVEL.SYS, string.format(
        "══ PROTOCOLO FINALIZADO · capas=%d · fallos=%d · resultado=%s ══",
        #SECURITY_LAYERS, layersFailed, overallSuccess and "ÉXITO TOTAL" or "PARCIAL"
    ))

    self.report = {
        success      = overallSuccess,
        layerResults = results,
        operator     = session.user.username,
        timestamp    = os.time(),
    }
    return self.report
end


-- ============================================================
--  MÓDULO 4 · NÚCLEO PRINCIPAL CON MANEJO DE ERRORES (pcall)
-- ============================================================

local OsxmaCore = {}
OsxmaCore.__index = OsxmaCore

--- Crea e inicializa todos los subsistemas.
--- @return table
function OsxmaCore.new()
    local self          = setmetatable({}, OsxmaCore)
    self.log            = Logger.new("CORE")
    self.auth           = AuthSystem.new()
    self.infiltration   = InfiltrationEngine.new(self.auth)
    return self
end

--- Wrapper seguro: ejecuta una función con pcall y loguea cualquier error.
--- @param fn    function  Función a ejecutar
--- @param ...             Argumentos para fn
--- @return boolean, any
function OsxmaCore:safeExec(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then
        self.log:emit(LOG_LEVEL.ERROR, string.format(
            "Excepción capturada → %s", tostring(result)
        ))
    end
    return ok, result
end

--- Punto de entrada del sistema.
function OsxmaCore:boot()
    self.log:emit(LOG_LEVEL.SYS, string.format(
        "Iniciando %s v%s", SYS_NAME, VERSION
    ))

    -- ── Fase 1: Autenticar todos los usuarios registrados ──
    local tokens = {
        "TKN-ALPHA-7X",   -- Co-Líder
        "TKN-BRAVO-3K",   -- Ingeniero: Israel
        "TKN-DELTA-9M",   -- Hacker: Michael
        "TKN-FAKE-0000",  -- Token inválido (prueba de error)
    }

    for _, token in ipairs(tokens) do
        local ok, result = self:safeExec(function()
            local success, msg = self.auth:authenticate(token)
            if not success then
                error(string.format("Fallo de auth [%s]: %s", token, msg))
            end
        end)
        _ = ok or self.log:emit(LOG_LEVEL.WARN, "Sistema continúa tras fallo de autenticación.")
    end

    -- ── Fase 2: Ejecutar protocolo de infiltración con el hacker ──
    self.log:emit(LOG_LEVEL.SYS, "Delegando protocolo al operador de seguridad.")
    local ok2, report = self:safeExec(function()
        return self.infiltration:runProtocol("TKN-DELTA-9M")
    end)

    if ok2 and report then
        self.log:emit(LOG_LEVEL.INFO, string.format(
            "Reporte recibido · operador=%s · éxito=%s",
            report.operator or "N/A",
            tostring(report.success)
        ))
    end

    -- ── Fase 3: Prueba de autorización cruzada ──
    self.log:emit(LOG_LEVEL.SYS, "Verificando permisos cruzados...")
    self.auth:authorize("TKN-BRAVO-3K", "BYPASS_SIM")   -- Ingeniero no debería tener este perm
    self.auth:authorize("TKN-ALPHA-7X", "OVERRIDE")      -- Co-Líder sí debe tenerlo

    -- ── Fase 4: Cierre de sesiones ──
    for _, token in ipairs({ "TKN-ALPHA-7X", "TKN-BRAVO-3K", "TKN-DELTA-9M" }) do
        self.auth:logout(token)
    end

    self.log:emit(LOG_LEVEL.SYS, "══ OSXMA:OVERRIDE · SHUTDOWN LIMPIO ══")
end


-- ============================================================
--  ENTRADA
-- ============================================================

local core = OsxmaCore.new()
core:boot()
