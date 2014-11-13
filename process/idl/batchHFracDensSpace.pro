pro batchHFracDensSpace, sstart, send, step

; File Options
directory = "/scratch/01707/mepa/Rad_1Mpc/RadCosmoLW_res128/"
file      = "/radCosmoLW_hdf5_chk_"
print, file

; Output Options
plotps = 0
plotgif = 1
charsize = 1.4

; Constants
amu = 1.66053892e-24
m_H = 1.00794 * amu

for number = sstart,send,step do begin

    if (number ge 1)   then prefix = '000'
    if (number ge 10)   then prefix = '00'
    if (number ge 100)  then prefix = '0'
    if (number ge 1000) then prefix = ''

    filename = directory + file + prefix + String(strcompress(number,/remove))
    print, filename

    ;;;;;
    ; get redshift of file
    file_identifier = H5F_OPEN(filename)
    dataset = H5D_OPEN(file_identifier, "real scalars")
    real_scalars = H5D_READ(dataset)
    for i=1, (size(real_scalars))[3] do begin
        if (stregex(real_scalars[i-1].name, '^scale', /BOOLEAN)) then scale = real_scalars[i-1].value
    endfor
    ;;;;;
    
    redshift = (1.0 / scale) - 1.0
    oneplusred = 1.0 + redshift
    
    print, "redshift = ", redshift
    outfile = 'plots/h/h_' + String(strcompress(number, /remove)) + '_z' + String(strcompress(redshift, /remove)) + '.png'    

    print, "reading density..."
    dens = loaddata_nomerge(filename,'dens')
    hfrac =  loaddata_nomerge(filename,'h')
    
    print, "***"
    print, "size of dens struct"
    print, size(dens)
    print, "***"


    dens = dens * oneplusred^3.0
    
    numdens = dens/1.67e-24

    print, hfrac(10)
    xr = [1e-5, 1e5]
    ;yr = [0.5e-5, 1] ;use for UV rad?
    yr = [0.5, 1] ;use for LW rad

    plot, numdens, hfrac, /xlog, /ylog, background='FFFFFF'xl, color=0, psym=3, xrange = xr, yrange=yr, xstyle=1, ystyle=1, xtitle='physical number density (cm^-3)', ytitle='hydrogen fraction'

    ;plot, numdens, hfrac, /xlog, /ylog, background='FFFFFF'xl, color=0, psym=3, xrange = xr,  xstyle=1, ystyle=1

    mytemp = fltarr(100)
    
    void = cgSnapshot(FILENAME=outfile, /NoDialog)
endfor

end
