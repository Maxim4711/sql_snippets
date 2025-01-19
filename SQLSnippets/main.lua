-- Pl/Sql Developer Lua Plug-In Addon: SQL Snippets
-- Variables
local AddMenu = ...
local plsql = plsql
local SYS, IDE, SQL = plsql.sys, plsql.ide, plsql.sql
local ShowMessage = plsql.ShowMessage

-- IUP initialization
local iup_initialized = false
local function init_iup()
    if iup_initialized then return true end
    
    local path = plsql.RootPath() .. '\\clibs\\'
    local iup_core = package.loadlib(path..'iup.dll', 'IupOpen')
    if not iup_core then
        ShowMessage("Failed to load IUP")
        return false
    end
    
    iup_core()
    local iup_init = package.loadlib(path..'iuplua51.dll', 'luaopen_iuplua')
    if not iup_init then
        ShowMessage("Failed to load IUP Lua bindings")
        return false
    end
    
    iup_init()
    iup_initialized = true
    return true
end

-- Get snippets file path
local function get_snippets_file()
    return plsql.RootPath() .. '\\SQLSnippets\\sql_snippets.txt'
end

-- Helper function to save snippet
local function saveSnippet(name, sql)
    -- Create directory if it doesn't exist
    local dir = plsql.RootPath() .. '\\SQLSnippets'
    os.execute('mkdir "' .. dir .. '" 2>nul')
    
    -- Append to file
    local file = io.open(get_snippets_file(), "a")
    if not file then
        ShowMessage("Cannot open snippets file for writing")
        return false
    end
    
    file:write("@@ " .. name .. " @@\n")
    file:write(sql .. "\n")
    file:close()
    return true
end

-- Add Snippet
do
    local function AddSnippet()
        -- Check window type first
        local windowType = IDE.GetWindowType()
        if windowType == 0 then
            ShowMessage("No active window")
            return
        end

        -- Try to get selected text
        local selectedSQL = IDE.GetSelectedText()
        if not selectedSQL or selectedSQL == "" then
            ShowMessage("Please select SQL text first")
            return
        end

        -- Initialize IUP
        if not init_iup() then return end

        -- Create dialog
        local dlg
        local nameInput = iup.text{value="", expand="YES"}
        
        local function okCallback()
            local name = nameInput.value
            if name and name ~= "" then
                if saveSnippet(name, selectedSQL) then
                    ShowMessage("Snippet saved successfully")
                end
                dlg:hide()
            else
                ShowMessage("Please enter a name for the snippet")
            end
        end
        
        dlg = iup.dialog{
            iup.vbox{
                iup.label{title="Enter snippet name:"},
                nameInput,
                iup.hbox{
                    iup.button{title="OK", action=okCallback},
                    iup.button{title="Cancel", action=function() dlg:hide() end},
                    margin="10x10",
                    gap="5"
                },
                margin="10x10",
                gap="5"
            },
            title="Add SQL Snippet",
            size="300x120"
        }
        
        dlg:popup(iup.CENTER, iup.CENTER)
        dlg:destroy()
    end
    AddMenu(AddSnippet, "Lua / SQL Snippets / Add Snippet")
end

-- Recall Snippet
do
    local function RecallSnippet()
        ShowMessage("Recall snippet clicked")
    end
    AddMenu(RecallSnippet, "Lua / SQL Snippets / Recall Snippet")
end

-- Addon description
local function About()
    return "SQL Snippets Manager"
end

return {
    OnActivate,
    OnDeactivate,
    CanClose,
    AfterStart,
    AfterReload,
    OnBrowserChange,
    OnWindowChange,
    OnWindowCreate,
    OnWindowCreated,
    OnWindowClose,
    BeforeExecuteWindow,
    AfterExecuteWindow,
    OnConnectionChange,
    OnWindowConnectionChange,
    OnPopup,
    OnMainMenu,
    OnTemplate,
    OnFileLoaded,
    OnFileSaved,
    About,
    CommandLine,
    RegisterExport,
    ExportInit,
    ExportFinished,
    ExportPrepare,
    ExportData
}