close,1
dir = '/Volumes/Scratch/hybrid/RT/RT_bhs/'

buffstat=1
cbt = 0.02
cbs = 1.3
;f_read_coord,rundir+'/coord.dat',x,y,z,dzc,dzg,nx,ny,nz

read_coords,dir,x,y,z

read_para,dir
restore,dir+'para.sav'

nframe=11

loadct,33
s_max = 255
s_min = 0
nnx = nx*2
nny = nz
stretch,s_min,s_max
device,decompose=0

zm = 2
ftsz=14

img = fltarr(nnx,nny,nframe)
 
; Initialize XINTERANIMATE: 
;XINTERANIMATE, SET=[zm*nnx,zm*nny, nfrm], /SHOWLOAD 
 
xsz = 2000/1.5
ysz = 1400/1.5
XINTERANIMATE, SET=[xsz,ysz, nframe], /SHOWLOAD 

video_file = 'RT.mp4'
video = idlffvideowrite(video_file)
framerate = 7.5
;wdims = w.window.dimensions
stream = video.addvideostream(xsz, ysz, framerate)



lnvy = fltarr(nframe)


for nfrm = 1,nframe,1 do begin 

   c_read_3d_m_32,dir,'c.np_b',nfrm,npb  
;   f_read_3d_m_32,rundir+'/np_b_1',i,npb
   c_read_3d_m_32,dir,'c.np',nfrm,npt
   c_read_3d_vec_m_32,dir,'c.b1',nfrm,b1
   c_read_3d_vec_m_32,dir,'c.up',nfrm,up
   c_read_3d_m_32,dir,'c.mixed',nfrm,mix  

   np = npt + npb
;   np = mix
;   np = npt
   print,min(np)

   

;   f_read_3d_vec_m_32,'run2/b1all_2',i,b1

;   lnvy(i-1) = alog(max(abs(up(*,1,30:120,2))))
;   h=bytscl(reform(np(*,1,*)))

;   h=rebin(reform(sqrt(b1(*,1,*,0)^2+b1(*,1,*,2)^2)),nnx,nny)
;   img(0:nx-1,*,i-1) = h(*,*)
;   img(nx-1:2*nx-3,*,i-1) = h(1:*,*)
;   xinteranimate, frame = i-1, image = img<s_max

   w = window(window_title='RT',dimensions=[xsz,ysz],margin=0,$
           buffer=buffstat)


   npimg = reform(np(*,1,*))

   img = fltarr(nx*2,nz)
   img(0:nx-1,*) = npimg(*,*)
   img(nx-1:2*nx-3,*) = npimg(1:*,*)
   xx = findgen(nx*2)*dx


   
   im = image(img,xx/dx,z/delz,rgb_table=33,$
              /current,layout=[2,2,1],$
              font_size = ftsz, axis_style=2, xtickdir=1,ytickdir=1,$
              dimensions=[xsz,ysz],buffer=buffstat)

   im.yrange=[0,nz-1]
   im.scale,1.5,1.5


   c = colorbar(target=im,orientation=1,textpos=1,font_size=ftsz)
   c.translate,-cbt,0,/normal
   c.scale,0.8,cbs

   im.refresh,/disable
   im.xtitle='x'
   im.ytitle='z'
;im1.xtitle='x (Rio)'
;im1.ytitle='z (Rio)'
   c.title='Density (cm$^{-3}$)'
   c.title='Mixing'


   img = fltarr(nx*2,nz,3)
   img(0:nx-1,*,*) = reform(up(*,1,*,*))
   img(nx-1:2*nx-3,*,*) = reform(up(1:*,1,*,*))

   xdot = reform(img(*,*,0))
   ydot = reform(img(*,*,2))
   s = STREAMLINE(xdot, ydot, xx/dx, z/delz, $
                  ARROW_COLOR="White", $
                  ARROW_OFFSET=[0.25,0.5,0.75,1], $
                  STREAMLINE_STEPSIZE=0.05,$
                  STREAMLINE_NSTEPS=40,$
                  ;POSITION=[0.1,0.22,0.95,0.9], $
                  X_STREAMPARTICLES=41, Y_STREAMPARTICLES=41,$
                  buffer=buffstat,/current,/overplot,layout=[2,2,2])

   s.THICK = 2
   s.aspect_ratio=1.0
   s.AUTO_COLOR = 1
;   s.AUTO_RANGE = [0.03,0.07]
   s.RGB_TABLE = 0
   s.arrow_size=0



   b1img = reform(b1(*,1,*,1))
   im = image(b1img,x/dx,z/delz,rgb_table=33,$
              /current,layout=[2,2,2],$
              font_size = ftsz, axis_style=2, xtickdir=1,ytickdir=1,$
              dimensions=[xsz,ysz],buffer=buffstat)

   im.yrange=[0,nz-1]
   im.scale,1.5,1.5
   
   xdot = reform(b1(*,1,*,0))
   ydot = reform(b1(*,1,*,2))
   s = STREAMLINE(xdot, ydot, x/dx, z/delz, $
                  ARROW_COLOR="White", $
                  ARROW_OFFSET=[0.25,0.5,0.75,1], $
                  STREAMLINE_STEPSIZE=150.0,$
                  STREAMLINE_NSTEPS=50,$
                  ;POSITION=[0.1,0.22,0.95,0.9], $
                  X_STREAMPARTICLES=21, Y_STREAMPARTICLES=41,$
                  buffer=buffstat,/current,/overplot,layout=[2,2,2])
;, $
;                  XTITLE='X', YTITLE='Y', $
;                  TITLE='Van der Pol Oscillator - Phase Portrait',)

   ; Change some properties.
   s.THICK = 2
   s.aspect_ratio=1.0
   s.AUTO_COLOR = 2
;   s.AUTO_RANGE = [0.03,0.07]
   s.RGB_TABLE = 0
   s.arrow_size = 0.0

   c = colorbar(target=im,orientation=1,textpos=1,font_size=ftsz)
;   c.translate,-cbt,0,/normal
;   c.scale,0.8,cbs

   im.refresh,/disable
   im.xtitle='x'
   im.ytitle='z'
;im1.xtitle='x (Rio)'
;im1.ytitle='z (Rio)'
   c.title='B'

   im = plot(x/dx,b1(*,1,nx/2,1),layout=[2,2,3],'2g',$
            yrange=[-0.05,0.05],/current,buffer=buffstat,$
            xrange=[0,max(x/dx)])
   im = plot(x/dx,5*b1(*,1,nx/2,0),layout=[2,2,3],'2r',/overplot,buffer=buffstat)
   im = plot(x/dx,5*b1(*,1,nx/2,2),layout=[2,2,3],'2b',/overplot,buffer=buffstat)


   upimg = reform(abs(up(*,1,*,2)))
   im = image(upimg/max(upimg),x/dx,z/delz,rgb_table=33,$
              /current,layout=[2,2,4],$
              font_size = ftsz, axis_style=2, xtickdir=1,ytickdir=1,$
              dimensions=[xsz,ysz],buffer=buffstat)

   im.yrange=[0,nz-1]
   im.scale,1.5,1.5

;   im = plot(x/dx,b1(*,1,130,1),layout=[2,2,4],'2g',$
;            yrange=[-0.05,0.05],/current,buffer=buffstat,$
;            xrange=[0,max(x/dx)])
;   im = plot(x/dx,5*b1(*,1,130,0),layout=[2,2,4],'2r',/overplot,buffer=buffstat;)
;   im = plot(x/dx,5*b1(*,1,130,2),layout=[2,2,4],'2b',/overplot,buffer=buffstat)






   im.refresh
   img = im.CopyWindow()





print, 'Time:', video.put(stream, im.copywindow())
   xinteranimate, frame = nfrm-1, image = img



endfor

;img = bytscl(img)

;img = bytscl(img)
;img(*,nz/2-96/2,*) = 255
;img(*,nz/2+96/2,*) = 255


;for i = 0,nfrm-1 do begin
;   xinteranimate, frame = i, image = rebin(img(*,*,i)<255,zm*nnx,zm*nny)
;endfor

;plot,lnvy

video.cleanup
xinteranimate,/keep_pixmaps



end
