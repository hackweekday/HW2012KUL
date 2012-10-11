#include<stdio.h>
#include<string.h>
#include<process.h>
#include<md5.h>

void main()
{
	MD5 md5;
	FILE *image1,*image2,*image3,*f1,*f2,*f3,*md;
	image1=fopen("..\\a.jpg","rb");
	image2=fopen("..\\b.jpg","rb");
	image3=fopen("..\\c.jpg","rb");
	f1=fopen("..\\a","a+");
	f2=fopen("..\\b","a+");
	f3=fopen("..\\c","a+");
	md=fopen("..\\md5","w+");
	char i,img[256],img1[20];
	int j=0,k=0,l=0;
	
	while(!feof(image1))
	{
		j+=10;
		fread(&i,sizeof(i),1,image1);
		if(j%2==0)
		{
			fwrite(&i,sizeof(i),1,f1);
			k++;
		}
		else if(j%3==0)
		{
			fseek(f1,26,SEEK_SET);
			fread(&i,sizeof(i),1,image1);
			fwrite(&i,sizeof(i),1,f1);
			k++;
		}
		else if(j/36>50)
		{
			fseek(f1,501,SEEK_SET);
			fread(&i,sizeof(i),1,image1);
			fwrite(&i,sizeof(i),1,f1);
			k++;
		}
		if(k>30)
			break;
		l++;
	}

	j=0;

	k=0;
	fseek(image2,0,SEEK_SET);
	while(!feof(image2))
	{
		j+=10;
		fread(&i,sizeof(i),1,image2);
		if(j%2==0)
		{
			fwrite(&i,sizeof(i),1,f2);
			k++;
		}
		else if(j%3==0)
		{
			fseek(f2,26,SEEK_SET);
			fread(&i,sizeof(i),1,image2);
			fwrite(&i,sizeof(i),1,f2);
			k++;
		}
		else if(j/36>50)
		{
			fseek(f2,501,SEEK_SET);
			fread(&i,sizeof(i),1,image2);
			fwrite(&i,sizeof(i),1,f2);
			k++;
		}
		if(k>30)
			break;
		l++;
	}
	j=0;
	k=0;
	fseek(image3,0,SEEK_SET);
	while(!feof(image3))
	{
		j+=10;
		fread(&i,sizeof(i),1,image3);
		if(j%2==0)
		{
			fwrite(&i,sizeof(i),1,f3);
			k++;
		}
		else if(j%3==0)
		{
			fseek(f3,26,SEEK_SET);
			fread(&i,sizeof(i),1,image3);
			fwrite(&i,sizeof(i),1,f3);
			k++;
		}
		else if(j/36>50)
		{
			fseek(f3,501,SEEK_SET);
			fread(&i,sizeof(i),1,image3);
			fwrite(&i,sizeof(i),1,f3);
			k++;
		}
		if(k>30)
			break;
		l++;
	}
	fseek(f1,0,SEEK_SET);
	l=0;
	while(!feof(f1))
	{
		img[l]=fgetc(f1);
		l++;
	}
	fseek(f2,0,SEEK_SET);
	while(!feof(f2))
	{
		img[l]=fgetc(f2);
		l++;
	}
	fseek(f3,0,SEEK_SET);
	while(!feof(f3))
	{
		img[l]=fgetc(f3);
		l++;
	}
	fputs(md5.digestString(img),md);
	
	
}