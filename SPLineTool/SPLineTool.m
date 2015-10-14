//
//  SPLineTool.m
//  test
//
//  Created by smallpay on 15/10/13.
//  Copyright © 2015年 xmg. All rights reserved.
//

#import "SPLineTool.h"

//
void ZG(double *A,double *B,double *C,double *G,int *LOGI,long count)
{
    //追赶法
    register long I = 0;
    long N = count;
    
    if(*LOGI == 0)
    {
        C[0] = C[0] / B[0];
        for(I = 1;I < N;I++)
        {
            B[I] = B[I] - A[I] * C[I-1];
            C[I] = C[I] / B[I];
        }
        A[0] = 0.;
        C[N-1] = 0.;
        *LOGI = 1;
    }
    G[0] = G[0] / B[0];
    for(I=1;I < N;I++)
    {
        G[I] = (G[I] - A[I] * G[I-1]) / B[I];
    }
    for(I = N-2;I > -1;I--)//DO 30 I=N-1,1,-1
    {
        G[I] = G[I] - C[I] * G[I+1];
    }
}

void SPLine4(double *X,double *Y,double *XI,double *YI,double *A,double *B,double *C,double *G,int *LOGI,int MD,long count)
{
    register long I = 0;
    double W1,W2,H = 0;
    long N = count;
    
    if(*LOGI == 0)
    {
        for(I = 1;I < N;I++)
        {
            B[I] = X[I] - X[I-1];
            C[I] = (Y[I] - Y[I-1]) / B[I];
        }
        for(I = 1;I < N;I++)
        {
            A[I] = B[I] + B[I+1];
            G[I] = 6. * (C[I+1] - C[I]) / A[I];
            A[I] = B[I] / A[I];
        }
        for(I = 1;I < N;I++)
        {
            C[I] = 1. - A[I];
            B[I] = 2.;
        }
        B[0] = 2.;
        B[N-1] = 2.;
        if(MD == 3)
        {
            C[0] = -1.;
            A[N-1] = -1.;
            A[0] = 0.;
            C[N-1] = 0.;
        }
        ZG(A,B,C,G,LOGI,count);
    }
    for(I = 1;I < N;I++)
    {
        if(*XI >= X[I-1] && *XI <= X[I])//GE LE
        {
            H = X[I] - X[I-1];
            W1 = X[I]- *XI;
            W2 = *XI - X[I-1];
            *YI = W1 * W1 * W1 * G[I-1] / 6. / H;
            *YI = *YI + W2 * W2 * W2 * G[I] / 6. / H;
            *YI = *YI + W1 * (Y[I-1] - G[I-1] * H * H/ 6.) / H;
            *YI = *YI + W2 * (Y[I] - G[I] * H * H / 6. ) / H;
        }
    }
}

double CalculateDistance(double x1,double y1,double x2,double y2)
{
    return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}


@implementation SPLinePoint
@synthesize X;
@synthesize Y;
@end


@implementation SPLineTool
+(NSArray *)SPLine:(NSArray *)points SM:(int)SM style:(SPLineStyle) style
{
    NSMutableArray * res = [NSMutableArray array];
    //
    double XI,YI,XX,YY = 0;
    register long i = 0;
    
    long N = [points count];
    long realN = (N-1) * SM + N;
    double A[N];
    double B[N];
    double C[N];
    double G[N];
    double X[N];
    double Y[N];
    double T[N];
    
    int LOGI = 0;
    long Bei,Yu = 0;
    SPLinePoint *pPoint = 0;

    for(i=0;i < N;i++)
    {
        pPoint=[points objectAtIndex:i];
        X[i]=pPoint->X;
        Y[i]=pPoint->Y;
    }
    //
    if(style == SPLineStyle_0)//pPointHead->X==pPointTail->X && pPointHead->Y==pPointTail->Y)
    {
        //file://闭合
        T[0] = 0;
        for(i = 0;i < N - 1;i++)
        {
            T[i+1] = T[i] + CalculateDistance(X[i],Y[i],X[i+1],Y[i+1]) + 0.000000001;
            T[i+1]=T[i] + CalculateDistance(X[i],Y[i],X[i+1],Y[i+1]) + 0.000000001;
        }
        LOGI = 0;
        YI = 0;
        for(i = 0;i < realN;i++)
        {
            Bei = i / (SM + 1);
            Yu = i % (SM + 1);
            if(Yu != 0)
            {
                XI = T[Bei] + (T[Bei+1] - T[Bei]) / (SM + 1) * Yu;
                SPLine4(T, Y, &XI, &YI, A, B, C, G, &LOGI, 3, N);
                YY = YI;//+Y[Bei];
            }
            else
            {
                YY = Y[Bei];
            }
            pPoint = [[SPLinePoint alloc] init];
            pPoint->Y = YY;
            [res addObject:pPoint];
            [pPoint release];
        }
        //
        LOGI = 0;
        YI = 0;
        for(i = 0;i < realN;i++)
        {
            Bei = i / (SM+1);
            Yu = i % (SM+1);
            if(Yu != 0)
            {
                XI = T[Bei] + (T[Bei+1] - T[Bei]) / (SM + 1) * Yu;
                SPLine4(T, X, &XI, &YI, A, B, C, G, &LOGI, 3, N);
                YY = YI;//+X[Bei];
            }
            else
            {
                YY = X[Bei];
            }
            pPoint = [res objectAtIndex:i];
            pPoint->X = YY;
        }
    }
    else if(style == SPLineStyle_1)
    {
        //file://x连续
        LOGI = 0;
        YI = 0;
        for(i = 0;i < realN;i++)
        {
            Bei = i / (SM + 1);
            Yu = i % (SM + 1);
            if(Yu != 0)
            {
                XI = X[Bei] + (X[Bei+1] - X[Bei]) / (SM + 1) * Yu;
                SPLine4(X, Y, &XI, &YI, A, B, C, G, &LOGI, 3, N);
                XX = XI;
                YY = YI;
            }
            else
            {
                XX = X[Bei];
                YY = Y[Bei];
            }
            pPoint = [[SPLinePoint alloc] init];
            pPoint->X = XX;
            pPoint->Y = YY;
            [res addObject:pPoint];
            [pPoint release];
        }
    }
    else
    {
        //file://y连续
        LOGI = 0;
        YI = 0;
        for(i = 0;i < realN;i++)
        {
            Bei = i / (SM + 1);
            Yu = i % (SM + 1);
            if(Yu != 0)
            {
                XI = Y[Bei] + (Y[Bei + 1] - Y[Bei]) / (SM + 1) * Yu;
                SPLine4(Y, X, &XI, &YI, A, B, C, G, &LOGI, 3, N);
                XX = YI;
                YY = XI;
            }
            else
            {
                XX = X[Bei];
                YY = Y[Bei];
            }
            pPoint = [[SPLinePoint alloc] init];
            pPoint->X = XX;
            pPoint->Y = YY;
            [res addObject:pPoint];
            [pPoint release];
        }
    }
  
    return res;
}

@end
