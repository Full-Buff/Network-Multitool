# Set up dependencies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Network Diagnostic Tool"
$form.Size = New-Object System.Drawing.Size(500, 600)
$form.StartPosition = "CenterScreen"

# Branding area (Title and Description)
$brandingLabel = New-Object System.Windows.Forms.Label
$brandingLabel.Text = "Network Diagnostics"
$brandingLabel.Font = New-Object System.Drawing.Font("Arial", 14,[System.Drawing.FontStyle]::Bold)
$brandingLabel.Size = New-Object System.Drawing.Size(300, 40)
$brandingLabel.Location = New-Object System.Drawing.Point(100, 10)
$form.Controls.Add($brandingLabel)

$descriptionLabel = New-Object System.Windows.Forms.Label
$descriptionLabel.Text = "Enter the server IP/Hostname to run diagnostics on."
$descriptionLabel.AutoSize = $true
$descriptionLabel.Location = New-Object System.Drawing.Point(100, 50)
$form.Controls.Add($descriptionLabel)

# Input box for server IP/Hostname
$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Location = New-Object System.Drawing.Point(100, 80)
$inputBox.Size = New-Object System.Drawing.Size(250, 20)
$form.Controls.Add($inputBox)

# Text box to show results
$resultsBox = New-Object System.Windows.Forms.TextBox
$resultsBox.Multiline = $true
$resultsBox.ScrollBars = "Vertical"
$resultsBox.Location = New-Object System.Drawing.Point(50, 150)
$resultsBox.Size = New-Object System.Drawing.Size(400, 300)
$form.Controls.Add($resultsBox)

# Export button (initially hidden, only shown after the tests)
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = "Export to HTML"
$exportButton.Location = New-Object System.Drawing.Point(200, 460)
$exportButton.Size = New-Object System.Drawing.Size(100, 30)
$exportButton.Visible = $false
$form.Controls.Add($exportButton)

# Run button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "Run Diagnostics"
$runButton.Location = New-Object System.Drawing.Point(200, 110)
$form.Controls.Add($runButton)

# Function to update results box
function Append-Results {
    param ([string]$text)
    $resultsBox.AppendText($text + "`r`n")
}

# Function to run network tests
function Run-NetworkTests {
    param ([string]$address)

    Append-Results "Running ping..."
    $pingResults = Test-Connection -ComputerName $address -Count 4 | Out-String
    Append-Results $pingResults

    Append-Results "Running traceroute..."
    $tracertResults = tracert $address | Out-String
    Append-Results $tracertResults

    Append-Results "Running pathping..."
    $pathpingResults = pathping $address | Out-String
    Append-Results $pathpingResults

    Append-Results "Running nslookup..."
    $nslookupResults = nslookup $address | Out-String
    Append-Results $nslookupResults

    # Enable export button after tests
    $exportButton.Visible = $true
}

# Export function
$exportButton.Add_Click({
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "HTML File (*.html)|*.html"
    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $htmlContent = "<html><body><h1>Network Diagnostic Results</h1><pre>" + ($resultsBox.Text) + "</pre></body></html>"
        [System.IO.File]::WriteAllText($saveFileDialog.FileName, $htmlContent)
        [System.Windows.Forms.MessageBox]::Show("Results exported successfully to " + $saveFileDialog.FileName)
    }
})

# Button action for running tests
$runButton.Add_Click({
    $address = $inputBox.Text
    if ([string]::IsNullOrEmpty($address)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a valid server IP or hostname.")
        return
    }

    # Clear previous results
    $resultsBox.Clear()

    # Run the network tests
    Run-NetworkTests -address $address
})

# Show the form
$form.ShowDialog()
