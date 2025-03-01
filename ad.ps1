# --- FUNÇÃO PROCURA USUÁRIOS ---
#
function Search-Users{
    # Limpar o DataGridView
    $dataGridView.Rows.Clear()
    
    $global:users = @()

    $global:users += Get-ADUser -Credential $credential -Filter "*" -Property Name, SamAccountName, LockedOut|
    Where-Object {$_.Enabled -eq $true -and $_.LockedOut -eq $true}

    # Adicionar os dados ao DataGridView
    foreach ($user in $global:users) {
        $row = $dataGridView.Rows.Add()
        $dataGridView.Rows[$row].Cells[0].Value = $user.Name
        $dataGridView.Rows[$row].Cells[1].Value = $user.SamAccountName
        $dataGridView.Rows[$row].Cells["UnlockButton"].Value = "Desbloquear"                      
        $dataGridView.Rows[$row].Cells["ResetButton"].Value = "Resetar"                      
    }
}
#
# --- FUNÇÃO PROCURA USUÁRIOS ---

# --- FUNÇÃO REMOVE CONTROLES ---
#
function Remove-Controls($panel) {
    foreach ($control in $panel.Controls) {
        $panel.Controls.Remove($control)
    }
}
#
# --- FUNÇÃO REMOVE CONTROLES ---

# --- FUNÇÃO APAGA TODOS OS PAINÉIS ---
#
function Erase-All{
     $panelUsers.Visible = $false
}
#
# --- FUNÇÃO APAGA TODOS OS PAINÉIS ---

# --- AUTENTICAÇÃO ---
#
while($true){
    $credential = Get-Credential
    if (!$credential.UserName) {
        exit
    }
    if($credential.UserName -notlike "*admin*"){
        Write-Host "Usuario nao permitido."
        continue
    }
    try{
        Get-ADUser -Credential $credential -Identity user | Out-Null
        clear
    }
    catch{
        Write-Host "Credenciais erradas."
        continue
    }
    break
}
#
# --- AUTENTICAÇÃO ---

# --- DEPENDÊNCIAS ---
#
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
#
# --- DEPENDÊNCIAS ---

# --- INICIANDO O WINFORM ---
#
$form = New-Object System.Windows.Forms.Form
$form.Text = "AD Manager"
$form.Size = New-Object System.Drawing.Size(640, 480)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("icons/icon.ico")
#
# --- INICIANDO O WINFORM ---

# --- CRIANDO OS PAINEIS ----
#
# PAINEL MENU PRINCIPAL
$panelMain = New-Object System.Windows.Forms.Panel
$panelMain.Size = $form.ClientSize
$panelMain.Dock = [System.Windows.Forms.DockStyle]::Fill

# PAINEL MENU DESBLOQUEAR
$panelUsers = New-Object System.Windows.Forms.Panel
$panelUsers.Size = $form.ClientSize
$panelUsers.Dock = [System.Windows.Forms.DockStyle]::Fill
#
# --- CRIANDO OS PAINEIS ---

#CRIANDO BOTÃO DE VOLTA
$buttonBack = New-Object System.Windows.Forms.Button
$buttonBack.Text = "Voltar"
$buttonBack.Location = "534, 12"
$buttonBack.Size = "83, 23"
$buttonBack.Add_Click({
 Erase-All
 $panelMain.Visible = $true
 $panelMain.Controls.Add($labelUser)
 Remove-Controls $panelUsers
})

# LABEL USUÁRIO LOGADO
$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Location = "12, 9"
$labelUser.AutoSize = $true
$labelUser.Text = "Usuario: $($credential.UserName)"
$panelMain.Controls.Add($labelUser)

# --- CONTROLES MENU PRINCIPAL ---
#
# BOTÃO DESBLOQUEIO
$buttonUsers = New-Object System.Windows.Forms.Button
$buttonUsers.Text = "Usuarios"
$buttonUsers.Location = "12, 27"
$buttonUsers.Size = "600, 23"
$buttonUsers.Add_Click({
 $panelMain.Visible = $false 
 $panelUsers.Visible = $true
 $panelUsers.Controls.Add($labelUser)
 $panelUsers.Controls.Add($buttonBack)
 $panelUsers.Controls.Add($buttonSearch)
 $panelUsers.Controls.Add($dataGridView)
 Search-Users
})
$panelMain.Controls.Add($buttonUsers)
#
# --- CONTROLES MENU PRINCIPAL ---

# --- CONTROLES MENU RESETAR/DESBLOQUEIO ---
#
# BOTÃO DE PESQUISA
$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Text = "Pesquisar"
$buttonSearch.Location = "12, 100"
$buttonSearch.Size = "157, 23"
$buttonSearch.Add_Click({
    Search-Users
})

# GRID DE USUÁRIOS
$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Size = New-Object System.Drawing.Size(605, 300)
$dataGridView.Location = New-Object System.Drawing.Point(12, 129)
$dataGridView.ColumnCount = 2 # Define a quantidade de colunas
$dataGridView.ColumnHeadersHeight = 30 # Define a altura do cabeçalho das colunas
$dataGridView.Columns[0].Width = 150 # Define a altura das colunas
$dataGridView.Columns[1].Width = 150 # Define a altura das colunas
$dataGridView.Columns[0].Name = "Nome" # Nome da coluna 1
$dataGridView.Columns[1].Name = "Usuario" # Nome da coluna 2
$dataGridView.RowTemplate.Height = 25 # Define a altura das linhas

# PERMISSÕES NO GRID DE USUÁRIOS
$dataGridView.AllowUserToAddRows = $false # Não permite que o usuário adicione linhas
$dataGridView.AllowUserToDeleteRows = $false # Não permite que o usuário elimine linhas
$dataGridView.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::DisableResizing # Impede que o usuário altere a altura do cabeçalho
$dataGridView.RowHeadersVisible = $false # Desabilita a exibição da coluna de seleção (row header)
$dataGridView.AllowUserToResizeColumns = $false # Não permite reajustar colunas
$dataGridView.AllowUserToResizeRows = $false # Não permite reajustar linhas
foreach ($column in $dataGridView.Columns) {
    $column.SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::NotSortable
    $column.ReadOnly = $true
}

# BOTÃO DE DESBLOQUEIO NO GRID DE USUÁRIOS
$buttonColumn = New-Object System.Windows.Forms.DataGridViewButtonColumn
$buttonColumn.Name = "UnlockButton"
$buttonColumn.HeaderText = "Desbloquear"
$dataGridView.Columns.Add($buttonColumn) | Out-Null

# BOTÃO DE RESET NO GRID DE USUÁRIOS
$buttonReset = New-Object System.Windows.Forms.DataGridViewButtonColumn
$buttonReset.Name = "ResetButton"
$buttonReset.HeaderText = "Reset"
$dataGridView.Columns.Add($buttonReset) | Out-Null

# EVENTO BOTÕES
$dataGridView.add_CellContentClick({
    param ($sender, $e)
    if ($e.RowIndex -ge 0){
        if ($e.ColumnIndex -eq $dataGridView.Columns["UnlockButton"].Index) {
            try{
                Unlock-ADAccount -Credential $credential -Identity $global:users[$e.RowIndex].SamAccountName
                [System.Windows.Forms.MessageBox]::Show("O usuario " + $global:users[$e.RowIndex].SamAccountName + " foi desbloqueado")
            }
            catch{
                [System.Windows.Forms.MessageBox]::Show("Não foi possível desbloquear o usuário" + $global:users[$e.RowIndex].SamAccountName)
            }
        }
        if ($e.ColumnIndex -eq $dataGridView.Columns["ResetButton"].Index){
            try{
                Unlock-ADAccount -Credential $credential -Identity $global:users[$e.RowIndex].SamAccountName            
                Set-ADAccountPassword -Credential $credential -Identity $global:users[$e.RowIndex].SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "psw" -Force)
                Set-Aduser -Credential $credential -Identity $global:users[$e.RowIndex].SamAccountName -ChangePasswordAtLogon $true            
                [System.Windows.Forms.MessageBox]::Show("O usuario " + $global:users[$e.RowIndex].SamAccountName + " foi resetado e a senha alterada para psw")
            }
            catch{
                [System.Windows.Forms.MessageBox]::Show("Não foi possível resetar o usuário" + $global:users[$e.RowIndex].SamAccountName)
            }               
        }
    }
    Search-Users
})
#
# --- CONTROLES MENU RESETAR/DESBLOQUEIO ---
 

Erase-All
$form.Controls.Add($panelMain)
$form.Controls.Add($panelUsers)
$form.ShowDialog()
