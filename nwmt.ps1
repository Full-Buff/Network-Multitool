# Set up dependencies for GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Network Multitool"
$form.Size = New-Object System.Drawing.Size(900, 1050) # Increased height for more padding at the bottom
$form.MinimumSize = New-Object System.Drawing.Size(900, 1050) # Increased minimum size
$form.StartPosition = "CenterScreen"
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font # Automatically scale the form

# Function to center elements horizontally
function Center-Control {
    param ($control, $form)
    $control.Left = [math]::Round(($form.ClientSize.Width - $control.Width) / 2)
}

# Branding area (Title and Description)
$brandingLabel = New-Object System.Windows.Forms.Label
$brandingLabel.Text = "Network Multitool"
$brandingLabel.Font = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold) # Font size
$brandingLabel.Size = New-Object System.Drawing.Size(700, 50) # Adjusted size for padding
$brandingLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter # Centered text alignment
$form.Controls.Add($brandingLabel)

$descriptionLabel = New-Object System.Windows.Forms.Label
$descriptionLabel.Text = "Enter the server IP/Hostname to run tests on."
$descriptionLabel.AutoSize = $true
$descriptionLabel.Font = New-Object System.Drawing.Font("Arial", 12)
$descriptionLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter # Centered text alignment
$form.Controls.Add($descriptionLabel)

# Input box for server IP/Hostname with placeholder
$inputBox = New-Object System.Windows.Forms.TextBox
$inputBox.Size = New-Object System.Drawing.Size(700, 25) # Width for input area
$inputBox.PlaceholderText = "Enter server IP or hostname here..." # Placeholder text (available in .NET Core/Framework 4.7.2+)
$form.Controls.Add($inputBox)

# Run button
$runButton = New-Object System.Windows.Forms.Button
$runButton.Text = "Run Tests"
$runButton.Size = New-Object System.Drawing.Size(180, 50) # Button size
$runButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold) # Button font and style
$form.Controls.Add($runButton)

# Text box to show results
$resultsBox = New-Object System.Windows.Forms.TextBox
$resultsBox.Multiline = $true
$resultsBox.ScrollBars = "Vertical"
$resultsBox.Size = New-Object System.Drawing.Size(800, 600) # Size of the results box
$form.Controls.Add($resultsBox)

# Export button (initially hidden, only shown after the tests)
$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = "Export Results"
$exportButton.Size = New-Object System.Drawing.Size(300, 50) # Made the button longer to ensure text fits
$exportButton.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold) # Button font and style
$exportButton.Visible = $false
$form.Controls.Add($exportButton)

# Set up layout and control positions
$form.Add_Shown({
    # Centering elements on the form
    Center-Control $brandingLabel $form
    $brandingLabel.Top = 30
    
    Center-Control $descriptionLabel $form
    $descriptionLabel.Top = 100
    
    Center-Control $inputBox $form
    $inputBox.Top = 140
    
    Center-Control $runButton $form
    $runButton.Top = 190
    
    Center-Control $resultsBox $form
    $resultsBox.Top = 260
    
    Center-Control $exportButton $form
    $exportButton.Top = 880 # Adjusted to give more bottom padding

    # Set the initial focus to the form itself to avoid focusing the input box on startup
    $form.Select()
})

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
        $htmlContent = "<html><body><h1>Network Multitool Results</h1><pre>" + ($resultsBox.Text) + "</pre></body></html>"
        [System.IO.File]::WriteAllText($saveFileDialog.FileName, $htmlContent)
        [System.Windows.Forms.MessageBox]::Show("Results exported successfully to " + $saveFileDialog.FileName)
    }
})

# Button action for running tests
$runButton.Add_Click({
    $address = $inputBox.Text
    if ([string]::IsNullOrEmpty($address) -or $address -eq "Enter server IP or hostname") {
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
